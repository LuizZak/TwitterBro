//
//  TweetJSONParser.m
//  PassagemDeViews
//
//  Created by LUIZ FERNANDO SILVA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import "TBJSONParser.h"

@implementation TBJSONParser

+ (TBAccount*)generateAccountForJSON:(NSDictionary*)json
{
    TBAccount *account = [[TBAccount alloc] init];
    
    account.origin = json;
    
    account.userName = [json objectForKey:@"name"];
    account.screenName = [json objectForKey:@"screen_name"];
    account.userID = [[json objectForKey:@"id"] unsignedLongLongValue];
    account.profileImageURL = [json objectForKey:@"profile_image_url"];
    
    return account;
}

+ (TBTweet*)generateTweetForJSON:(NSDictionary*)json
{
    TBTweet *tweet = [[TBTweet alloc] init];
    
    tweet.origin = json;
    
    tweet.createdAt = [json objectForKey:@"created_at"];
    tweet.tweetID = [[json objectForKey:@"id"] unsignedLongLongValue];
    tweet.tweet = [json objectForKey:@"text"];
    tweet.user = [TBJSONParser generateAccountForJSON:[json objectForKey:@"user"]];
    
    //id obj = [[json objectForKey:@"entities"] objectForKey:@"hashtags"][0];
    NSArray *hashtags = [[json objectForKey:@"entities"] objectForKey:@"hashtags"];
    NSArray *media = [[json objectForKey:@"entities"] objectForKey:@"media"];
    NSArray *urls = [[json objectForKey:@"entities"] objectForKey:@"urls"];
    NSArray *mentions = [[json objectForKey:@"entities"] objectForKey:@"user_mentions"];
    
    NSMutableArray *hashtagObjects = [[NSMutableArray alloc] init];
    NSMutableArray *mediaObjects = [[NSMutableArray alloc] init];
    NSMutableArray *urlObjects = [[NSMutableArray alloc] init];
    NSMutableArray *userMentionObjects = [[NSMutableArray alloc] init];
    
    for(NSDictionary *hashtag in hashtags)
    {
        [hashtagObjects addObject:[TBJSONParser generateTweetHashtagForJSON:hashtag]];
    }
    
    for(NSDictionary *mediaobj in media)
    {
        [mediaObjects addObject:[TBJSONParser generateTweetMediaForJSON:mediaobj]];
    }
    
    for(NSDictionary *url in urls)
    {
        [urlObjects addObject:[TBJSONParser generateTweetURLForJSON:url]];
    }
    
    for(NSDictionary *mention in mentions)
    {
        [userMentionObjects addObject:[TBJSONParser generateTweetUserMentionForJSON:mention]];
    }
    
    tweet.hashtags = hashtagObjects;
    tweet.media = mediaObjects;
    tweet.links = urlObjects;
    tweet.userMentions = userMentionObjects;
    
    return tweet;
}

// Gera um objeto TBTweetHashtag a partir de um JSON codificado como NSDictionary
+ (TBTweetHashtag*)generateTweetHashtagForJSON:(NSDictionary*)json
{
    TBTweetHashtag *tweetHashtag = [[TBTweetHashtag alloc] init];
    
    tweetHashtag.indexStart = [[json objectForKey:@"indices"][0] intValue];
    tweetHashtag.indexEnd = [[json objectForKey:@"indices"][1] intValue];
    tweetHashtag.hashtag = [json objectForKey:@"text"];
    
    return tweetHashtag;
}

// Gera um objeto TBTweetMedia a partir de um JSON codificado como NSDictionary
+ (TBTweetMedia*)generateTweetMediaForJSON:(NSDictionary*)json
{
    TBTweetMedia *tweetMedia = [[TBTweetMedia alloc] init];
    
    tweetMedia.type = [json objectForKey:@"type"];
    tweetMedia.indexStart = [[json objectForKey:@"indices"][0] intValue];
    tweetMedia.indexEnd = [[json objectForKey:@"indices"][1] intValue];
    tweetMedia.url = [json objectForKey:@"text"];
    tweetMedia.displayURL = [json objectForKey:@"display_url"];
    tweetMedia.expandedURL = [json objectForKey:@"expanded_url"];
    tweetMedia.mediaUrl = [json objectForKey:@"media_url"];
    
    NSDictionary *sizes = [json objectForKey:@"sizes"];
    
    // Decodifica as dimensões da mídia
    if(sizes != nil)
    {
        tweetMedia.sizeThumbnail = [TBJSONParser generateMediaSizeForJSON:[sizes objectForKey:@"thumb"]];
        tweetMedia.sizeSmall = [TBJSONParser generateMediaSizeForJSON:[sizes objectForKey:@"small"]];
        tweetMedia.sizeMedium = [TBJSONParser generateMediaSizeForJSON:[sizes objectForKey:@"medium"]];
        tweetMedia.sizeLarge = [TBJSONParser generateMediaSizeForJSON:[sizes objectForKey:@"large"]];
    }
    
    return tweetMedia;
}

/*
{
   "type":"photo",
   "sizes":{
      "thumb":{
         "h":150,
         "resize":"crop",
         "w":150
      },
      "large":{
         "h":238,
         "resize":"fit",
         "w":226
      },
      "medium":{
         "h":238,
         "resize":"fit",
         "w":226
      },
      "small":{
         "h":238,
         "resize":"fit",
         "w":226
      }
   }
}
 */

// Gera um objeto TBTweetURL a partir de um JSON codificado como NSDictionary
+ (TBTweetURL*)generateTweetURLForJSON:(NSDictionary*)json
{
    TBTweetURL *tweetURL = [[TBTweetURL alloc] init];
    
    tweetURL.indexStart = [[json objectForKey:@"indices"][0] intValue];
    tweetURL.indexEnd = [[json objectForKey:@"indices"][1] intValue];
    tweetURL.url = [json objectForKey:@"text"];
    tweetURL.displayURL = [json objectForKey:@"display_url"];
    tweetURL.expandedURL = [json objectForKey:@"expanded_url"];
    
    return tweetURL;
}

// Gera um objeto TBTweetUserMention a partir de um JSON codificado como NSDictionary
+ (TBTweetUserMention*)generateTweetUserMentionForJSON:(NSDictionary*)json
{
    TBTweetUserMention *tweetMention = [[TBTweetUserMention alloc] init];
    
    tweetMention.indexStart = [[json objectForKey:@"indices"][0] intValue];
    tweetMention.indexEnd = [[json objectForKey:@"indices"][1] intValue];
    tweetMention.userName = [json objectForKey:@"screen_nome"];
    tweetMention.userID = [[json objectForKey:@""] unsignedLongLongValue];
    
    return tweetMention;
}

// Gera uma struct TBMediaSize a partir de um JSON codificado como NSDictionary
+ (TBMediaSize)generateMediaSizeForJSON:(NSDictionary*)json
{
    TBMediaSize mediaSize;
    
    mediaSize.exists = YES;
    mediaSize.width = [[json objectForKey:@"w"] intValue];
    mediaSize.height = [[json objectForKey:@"h"] intValue];
    
    NSString *resizeMode = [json objectForKey:@"resize"];
    
    if([resizeMode isEqualToString:@"crop"])
        mediaSize.resizeMode = TBMediaSizeCrop;
    else
        mediaSize.resizeMode = TBMediaSizeFit;
    
    return mediaSize;
}

@end