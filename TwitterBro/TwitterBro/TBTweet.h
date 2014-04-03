//
//  Tweet.h
//  PassagemDeViews
//
//  Created by LUIZ FERNANDO SILVA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBObject.h"
#import "TBAccount.h"

typedef enum {
    TBMediaSizeCrop,
    TBMediaSizeFit
} TBMediaSizeResize;

typedef struct {
    BOOL exists;
    int width;
    int height;
    TBMediaSizeResize resizeMode;
} TBMediaSize;

// TBTweetEntity
@interface TBTweetEntity : NSObject

// Índice de começo da entidade no texto do tweet
@property int indexStart;
// Índice de fim da entidade no texto do tweet
@property int indexEnd;

@end

// TBTweetHashtag
@interface TBTweetHashtag : TBTweetEntity
// Hashtag (sem o '#')
@property NSString *hashtag;

@end

// TBTweetURL
@interface TBTweetURL : TBTweetEntity

// URL
@property NSString *url;
// URL de display
@property NSString *displayURL;
// URL expandida
@property NSString *expandedURL;

@end

// TBTweetMedia
@interface TBTweetMedia : TBTweetURL

// O tipo de midia apresentado
@property NSString *type;
// O URL da mídia
@property NSString *mediaUrl;

// O tamanho grande da mídia
@property TBMediaSize sizeLarge;
// O tamanho médio da mídia
@property TBMediaSize sizeMedium;
// O tamanho pequeno da mídia
@property TBMediaSize sizeSmall;
// O tamanho de thumbnail da mídia
@property TBMediaSize sizeThumbnail;

@end

// TBUserMention
@interface TBTweetUserMention : TBTweetEntity

// Nome de usuário (sem o '@')
@property NSString *userName;
// ID do usuário
@property unsigned long long userID;

@end

// TBTweet
@interface TBTweet : TBObject

// O ID do tweet
@property unsigned long long tweetID;

// Data em que o tweet foi criado
@property NSDate *createdAt;

// Texto to tweet
@property NSString *tweet;

// Array de hashtags contidos no tweet
@property NSArray *hashtags;
// Array de media contidos do tweet
@property NSArray *media;
// Array de links contidos no tweet
@property NSArray *links;
// Array de user mentions no tweet
@property NSArray *userMentions;

// Conta que tweetou este tweet
@property TBAccount *user;

@end