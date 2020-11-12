import React, { useCallback, useEffect, useState } from 'react'
import { useHistory } from 'react-router-dom'
import { useMutation } from 'relay-hooks'
import GoogleLogin from 'react-google-login'
import { Box, Button, TextField } from '@material-ui/core'

import routes from '../app/routes'
import { LocalStorageKeys } from '../app/types'
import { userLoginMutation, LoginInput } from '../__generated__/userLoginMutation.graphql'
import { USER_LOGIN_MUTATION } from '../queries/user'

import Form from './Form'

export default function Login() {
  const history = useHistory()

  const [login, { data }] = useMutation<userLoginMutation>(USER_LOGIN_MUTATION)
  const [email, setEmail] = useState<string>('')

  useEffect(() => {
    if (data) {
      const { token, user } = data.login?.result!

      localStorage.setItem(LocalStorageKeys.Token, token)
      if (user.nickname) {
        history.push(routes.Lobby)
      }
    }
  }, [data, history])

  const onSignIn = useCallback(
    ({ profileObj }) => {
      const loginVariables: LoginInput = { email: profileObj.email, googleId: profileObj.googleId }

      login({
        variables: {
          input: loginVariables,
        },
      })
    },
    [login],
  )

  const onSignInWithoutGoogle = useCallback(() => {
    const loginVariables: LoginInput = { email, googleId: 'id_' + email }

    login({
      variables: {
        input: loginVariables,
      },
    })
  }, [email, login])

  return (
    <Box textAlign="center" mt="25vh">
      <h1>BAO BAO WANG</h1>

      {data ? (
        <Form />
      ) : (
        <>
          <div>
            <TextField
              label="Email"
              variant="outlined"
              onChange={(event: any) => setEmail(event.target.value)}
              value={email}
            ></TextField>
            <br />
            <Button color="primary" variant="contained" onClick={onSignInWithoutGoogle}>
              Login
            </Button>
          </div>
          <GoogleLogin
            clientId={process.env.REACT_APP_GOOGLE_CLIENT_ID + '.apps.googleusercontent.com'}
            buttonText="Login"
            onSuccess={onSignIn}
            onFailure={() => {}}
            cookiePolicy={'single_host_origin'}
          />
        </>
      )}
    </Box>
  )
}
