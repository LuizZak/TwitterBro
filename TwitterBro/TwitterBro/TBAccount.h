//
//  Conta.h
//  PassagemDeViews
//
//  Created by LUIZ FERNANDO SILVA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBObject.h"

@interface TBAccount : TBObject

// O ID do usuário
@property unsigned long long userID;

// O nome de usuário
@property NSString *userName;

// O nome de visualização (ou '@') usado pelo usuáro
@property NSString *screenName;

// A URL que aponta para a imagem do profile do usuário
@property NSString *profileImageURL;

@end