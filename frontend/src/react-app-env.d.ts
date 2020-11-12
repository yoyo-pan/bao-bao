/// <reference types="react-scripts" />
declare module 'babel-plugin-relay/macro' {
  export { graphql } from 'react-relay'
}

declare module '@absinthe/socket-relay' {
  export function createSubscriber(socket: any)
}
