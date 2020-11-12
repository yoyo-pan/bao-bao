import { graphql } from 'babel-plugin-relay/macro'

export const USER_LOGIN_MUTATION = graphql`
  mutation userLoginMutation($input: LoginInput!) {
    login(input: $input) {
      result {
        user {
          email
          googleId
          nickname
        }
        token
      }
    }
  }
`

export const USER_UPDATE_MUTATION = graphql`
  mutation userUpdateNicknameMutation($input: UpdateNicknameInput!) {
    updateNickname(input: $input) {
      result {
        nickname
      }
    }
  }
`
