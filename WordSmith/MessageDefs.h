//
//  MessageDefs.h
//  WordSmith
//
//  Created by Joseph Constan on 12/17/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#ifndef WordSmith_MessageDefs_h
#define WordSmith_MessageDefs_h

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeScore,
    kMessageTypeGameOver
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
    unichar letter;
} MessageMove;

typedef struct {
    Message message;
    NSInteger score;
} MessageScore;

typedef struct {
    Message message;
    BOOL disconnect;
} MessageGameOver;

#endif
