import React, { useState, useRef, useEffect, useCallback } from 'react'
import { Button } from '@material-ui/core'

import { Chat } from '../../types'
import useStyle from './style'

interface Props {
  chatHistory: Chat[]
  isInGame?: boolean
  onMessageSend: (message: String) => void
  onTypingStatusChange?: (isTyping: boolean) => void
}

const defaultProps = {
  chatHistory: [],
  onMessageSend: () => {},
  isInGame: false,
}

export default function Chatbox(props: Props = defaultProps) {
  const { chatHistory, onMessageSend, isInGame, onTypingStatusChange } = props
  const [textMessage, setTextMessage] = useState('')
  const [inputFocus, setInputFocus] = useState(false)
  const inputChat = useRef<HTMLInputElement>(null)
  const classes = useStyle()

  const onChatSubmit = useCallback(() => {
    if (textMessage) {
      onMessageSend(textMessage)
      setTextMessage('')
    }
    if (isInGame) inputChat.current?.blur()
  }, [textMessage, onMessageSend, isInGame])
  const onWindowKeypress = useCallback(
    (e: KeyboardEvent) => {
      if (e.which === 13 && !inputFocus) inputChat.current?.focus()
    },
    [inputChat, inputFocus],
  )
  const onFocusChange = useCallback(
    (isFocus: boolean) => {
      onTypingStatusChange?.(isFocus)
      setInputFocus(isFocus)
    },
    [onTypingStatusChange],
  )

  const getBlurClass = useCallback(
    (className: String) => {
      if (!isInGame) return ''
      return inputFocus ? '' : className
    },
    [inputFocus, isInGame],
  )

  useEffect(() => {
    window.addEventListener('keypress', onWindowKeypress)

    return () => {
      window.removeEventListener('keypress', onWindowKeypress)
    }
  }, [onWindowKeypress])

  return (
    <div className={classes.container}>
      <div className={`${classes.chatHistory} ${getBlurClass(classes.historyBlur)}`}>
        <ul>
          {chatHistory.map((chat, idx) => {
            return (
              <li key={idx}>
                <div className="name">
                  {chat.name} <span>({chat.receivedAt})</span>
                </div>
                <div className="bubble">{chat.message}</div>
              </li>
            )
          })}
        </ul>
      </div>
      <div className={`${classes.chatInput} ${getBlurClass(classes.inputBlur)}`}>
        <input
          ref={inputChat}
          type="text"
          placeholder="Hit enter to type"
          value={textMessage}
          onChange={e => {
            setTextMessage(e.target.value)
          }}
          onKeyPress={e => {
            if (e.which === 13) onChatSubmit()
            if (textMessage.length >= 30) e.preventDefault()
          }}
          onBlur={_ => onFocusChange(false)}
          onFocus={_ => onFocusChange(true)}
        />
        <Button variant="contained" color="primary" onClick={onChatSubmit}>
          send
        </Button>
      </div>
    </div>
  )
}
