import {
  CacheConfig,
  Environment,
  Network,
  RecordSource,
  RequestParameters,
  Store,
  Variables,
  Observable,
} from 'relay-runtime'
import * as withAbsintheSocket from '@absinthe/socket'
import { Socket as PhoenixSocket } from 'phoenix'

import { LocalStorageKeys } from '../app/types'

const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT!
const SUBSCRIPTION_ENDPOINT = process.env.REACT_APP_SUBSCRIPTION_ENDPOINT!

async function fetchRelay(params: RequestParameters, variables: Variables, _cacheConfig: CacheConfig) {
  const token = localStorage.getItem(LocalStorageKeys.Token)
  const response = await fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token
        ? {
            Authorization: `Bearer ${token}`,
          }
        : null),
    },
    body: JSON.stringify({
      query: params.text,
      variables,
    }),
  })

  const json = await response.json()

  if (Array.isArray(json.errors)) {
    throw json.errors
  }

  return json
}

let absintheSocket

function handleSubscribe(operation: RequestParameters, variables: Variables) {
  absintheSocket = withAbsintheSocket.create(
    new PhoenixSocket(SUBSCRIPTION_ENDPOINT, {
      params: {
        Authorization: `Bearer ${localStorage.getItem(LocalStorageKeys.Token)}`,
      },
    }),
  )
  const notifier = withAbsintheSocket.send(absintheSocket, {
    operation: operation.text!,
    variables,
  })

  const updatedNotifier = withAbsintheSocket.toObservable(absintheSocket, notifier, {
    onError: e => console.log('Error', e),
    onStart: n => console.log('Start', n),
    unsubscribe: () => {
      console.log('unsubscribe')
    },
  })

  return Observable.from(updatedNotifier) as any
}

export default new Environment({
  network: Network.create(fetchRelay, handleSubscribe),
  store: new Store(new RecordSource(), {
    gcReleaseBufferSize: 10,
  }),
})
