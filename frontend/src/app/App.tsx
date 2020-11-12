import React from 'react'
import { HashRouter, Switch, Route } from 'react-router-dom'

import routes from './routes'
import Game from '../game/Game'
import Lobby from '../lobby/Lobby'
import Login from '../login/Login'
import Room from '../room/Room'
import socket from '../channels/socket'

socket.connect()

function App() {
  return (
    <HashRouter>
      <Switch>
        <Route exact path={routes.Room}>
          <Room />
        </Route>
        <Route exact path={routes.Game}>
          <Game />
        </Route>
        <Route exact path={routes.Login}>
          <Login />
        </Route>
        <Route exact path={routes.Lobby}>
          <Lobby />
        </Route>
      </Switch>
    </HashRouter>
  )
}

export default App
