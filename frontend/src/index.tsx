import React from 'react'
import ReactDOM from 'react-dom'
import { RelayEnvironmentProvider } from 'relay-hooks'
import RelayEnvironment from './relay/RelayEnvironment'
import App from './app/App'

ReactDOM.render(
  <React.StrictMode>
    <RelayEnvironmentProvider environment={RelayEnvironment}>
      <App />
    </RelayEnvironmentProvider>
  </React.StrictMode>,
  document.getElementById('root'),
)
