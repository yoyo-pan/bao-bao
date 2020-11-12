import { graphql } from 'babel-plugin-relay/macro'

export const ROOM_JOIN_MUTATION = graphql`
  mutation roomJoinMutation($roomId: Int!) {
    joinRoom(roomId: $roomId) {
      result {
        idNumber
        host {
          nickname
        }
      }
      successful
    }
  }
`

export const ROOM_CREATE_MUTATION = graphql`
  mutation roomCreateMutation {
    createRoom {
      result {
        idNumber
        host {
          nickname
        }
      }
      successful
    }
  }
`

export const ROOM_LEAVE_MUTATION = graphql`
  mutation roomLeaveMutation {
    leaveRoom {
      result {
        idNumber
        host {
          nickname
        }
      }
      successful
    }
  }
`

export const ROOM_KICK_MUTATION = graphql`
  mutation roomKickMutation($userId: ID!) {
    kickPlayer(userId: $userId) {
      result {
        players {
          user {
            nickname
          }
        }
      }
      successful
    }
  }
`

export const ROOM_UPDATED_SUBSCRIPTION = graphql`
  subscription roomUpdatedSubscription {
    roomUpdated {
      id
      idNumber
      host {
        id
      }
      players {
        user {
          id
          nickname
        }
        isReady
      }
    }
  }
`

export const ROOM_READY_MUTATION = graphql`
  mutation roomReadyMutation {
    ready { successful }
  }
`

export const ROOM_UNREADY_MUTATION = graphql`
  mutation roomUnreadyMutation {
    unready { successful }
  }
`
