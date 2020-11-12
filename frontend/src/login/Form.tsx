import React, { useCallback, useState } from 'react'
import { useMutation } from 'relay-hooks'
import { useHistory } from 'react-router-dom'
import { TextField, Button, makeStyles } from '@material-ui/core'

import routes from '../app/routes'
import { userUpdateNicknameMutation } from '../__generated__/userUpdateNicknameMutation.graphql'
import { USER_UPDATE_MUTATION } from '../queries/user'

const useStyles = makeStyles({
  btn: {
    width: 194,
    marginTop: 24,
  },
})

export default function Form() {
  const history = useHistory()
  const classes = useStyles()
  const [update] = useMutation<userUpdateNicknameMutation>(USER_UPDATE_MUTATION)
  const [nickname, setNickname] = useState<string>('')

  const onSubmit = useCallback(() => {
    update({
      variables: {
        input: {
          nickname,
        },
      },
      onCompleted: () => {
        history.push(routes.Lobby)
      },
    })
  }, [update, history, nickname])

  return (
    <section>
      <form>
        <TextField
          label="Nickname"
          variant="outlined"
          onChange={event => setNickname(event.target.value)}
          value={nickname}
        ></TextField>
        <br />
        <Button className={classes.btn} variant="contained" color="primary" onClick={onSubmit}>
          Submit
        </Button>
      </form>
    </section>
  )
}
