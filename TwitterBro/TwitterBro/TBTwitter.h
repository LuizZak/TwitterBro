//
//  Twitter.h
//  PassagemDeViews
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TBImports.h"

// TwitterObserver
@protocol TBTwitterObserver <NSObject>

@optional

// Ocorre quando a API estiver pronta para enviar/receber dados.
// Este método é chamado em todos os observers quando uma conexão é
// autenticada, e é chamada também nos observers individuais quando eles
// são inseridos na API e ela já está pronta.
- (void)twitterDidBecomeReady;

// Ocorre quando o usuário é autenticado pelo serviço do twitter
- (void)twitterDidAuthenticateUser:(ACAccount*)account;

// Ocorre quando um erro de autentica
- (void)twitterDidFailAuthehticateUser:(NSError*)error;

// Ocorre quando uma requisição é respondida com um erro
- (void)twitterDidReceiveError:(long)requestId errors:(NSArray*)errorsArray;

// AEHUEHUEHUEHEUHE
- (void)twitterDidReceiveData:(NSData*)data requestId:(long)requestId error:(NSError*)error;

// Método chamado toda vez que um usuário é recebido pelo singleton do twitter
- (void)twitterDidReceiveUser:(TBAccount*)account requestId:(long)requestId error:(NSError*)error;

// Método chamado toda vez que um tweet é recebido pelo singleton do Twitter
- (void)twitterDidReceiveTweet:(TBTweet*)tweet requestId:(long)requestId error:(NSError*)error;

// Método chamado toda vez que vários tweets são recebidos via busca por texto, hashtag ou timeline
- (void)twitterDidReceiveMultipleTweets:(NSArray*)tweets requestId:(long)requestId error:(NSError*)error;

@end

// Twitter
@interface TBTwitter : NSObject
{
    NSMutableArray *observers;
    long internalRequestId;
    BOOL auth;
}

@property ACAccountStore *accountStore;
@property ACAccountType *accountType;
@property ACAccount *twitterAccount;
@property NSArray *loadedAccounts;
@property NSString *hashTagEscolhida;
@property NSArray *dataRecebida;

// Define se o twitter foi autenticado
@property (readonly) BOOL authenticated;

// Perfil atual do usuário
@property TBAccount *twitterProfile;

+ (TBTwitter *) twitter;

// Adiciona um observer para receber eventos assícronos da classe singleton
- (void)addObserver:(id<TBTwitterObserver>)observer;

// Remove um observer desta classe para ele parar de receber eventos assícronos desta classe
- (void)removeObserver:(id<TBTwitterObserver>)observer;

- (void)tweet:(UIViewController*)view text:(NSString*)text image:(UIImage *)image;

// Busca um usuário por user name (o '@') e notifica os observers quando achar
- (long)searchUserByName:(NSString*)userName callback:(void (^)(long, TBAccount*))callbackBlock;
// Busca um usuário por user name (o '@') e notifica os observers quando achar
- (long)searchUserByID:(unsigned long long)userID callback:(void (^)(long, TBAccount*))callbackBlock;

// Busca um tweet por id e notifica os observers quando achar
- (long)buscarTweetPorID:(unsigned long long)tweetId callback:(void (^)(long, TBTweet*))callbackBlock;

// Busca tweets que contém as hashtags dispostas na array especificada
- (long)searchTweetsWithTerms:(NSArray*)termsArray maxResultCount:(int)maxResults callback:(void (^)(long, NSMutableArray*))callbackBlock;

@end