//
//  TweetJSONParser.h
//  PassagemDeViews
//
//  Created by LUIZ FERNANDO SILVA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBAccount.h"
#import "TBTweet.h"

// Classe responsável por parsear arquivos JSON cuspidos pelo webservice do twitter
@interface TBJSONParser : NSObject

// Gera um objeto TBAccount a partir de um JSON codificado como NSDicionary
+ (TBAccount*)generateAccountForJSON:(NSDictionary*)json;
// Gera um objeto TBTweet a partir de um JSON codificado como NSDicionary
+ (TBTweet*)generateTweetForJSON:(NSDictionary*)json;

// Gera um objeto TBTweetHashtag a partir de um JSON codificado como NSDictionary
+ (TBTweetHashtag*)generateTweetHashtagForJSON:(NSDictionary*)json;
// Gera um objeto TBTweetMedia a partir de um JSON codificado como NSDictionary
+ (TBTweetMedia*)generateTweetMediaForJSON:(NSDictionary*)json;
// Gera um objeto TweetURL a partir de um JSON codificado como NSDictionary
+ (TBTweetURL*)generateTweetURLForJSON:(NSDictionary*)json;
// Gera um objeto TBTweetUserMention a partir de um JSON codificado como NSDictionary
+ (TBTweetUserMention*)generateTweetUserMentionForJSON:(NSDictionary*)json;

/*
 // TBTweetEntity
 @interface TBTweetEntity : NSObject
 
 // Índice de começo da entidade no texto do tweet
 @property int indexStart;
 // Índice de fim da entidade no texto do tweet
 @property int indexEnd;
 
 @end
 
 // TBTweetHashtag
 @interface TBHashtag : TBTweetEntity
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
 
 // TBUserMention
 @interface TBUserMention : TBTweetEntity
 
 // Nome de usuário (sem o '@')
 @property NSString *userName;
 // ID do usuário
 @property unsigned long long userID;
 
 @end*/

@end