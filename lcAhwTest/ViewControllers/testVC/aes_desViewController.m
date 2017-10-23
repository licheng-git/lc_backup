//
//  aes_desViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/11/20.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "aes_desViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#import "AESCrypt.h"

@implementation aes_desViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"AES/DES";
    
    NSString *testStr = @"E91174C3-52C6-47A7-9BAC-59C46D0D5200 啊哈 abc123";
    NSString *keyStr_des = @"3a2156h7";  // 密钥      （des为8位，aes128为16位）
    NSString *ivStr = @"7a2156h3";       // 偏移向量   （可空）
    
    NSString *desStr = [self kk_desEncrypt:testStr key:keyStr_des iv:ivStr];
    NSLog(@"des密文 %@", desStr);
    NSString *unDesStr = [self kk_desDecrypt:desStr key:keyStr_des iv:ivStr];
    NSLog(@"des明文 %@", unDesStr);

    NSString *keyStr_aes = @"1234567891234567";
    
    NSString *aesStr = [self kk_aesEncrypt:testStr key:keyStr_aes iv:nil];
    NSLog(@"aes密文 %@", aesStr);
    NSString *unAesStr = [self kk_aesDecrypt:aesStr key:keyStr_aes iv:nil];
    NSLog(@"aes明文 %@", unAesStr);
    
    NSString *aesStr1 = [AESCrypt encrypt:testStr password:keyStr_aes];
    NSLog(@"aes1密文 %@", aesStr1);
    NSString *unAesStr1 = [AESCrypt decrypt:aesStr1 password:keyStr_aes];
    NSLog(@"aes1明文 %@", unAesStr1);
}


// des加密
- (NSString *)desEncrypt:(NSString *)plainStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char key[8];
    memcpy(key, keyData.bytes, keyData.length);
    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger len = ivData.length;
    unsigned char iv[len];
    memcpy(iv, ivData.bytes, len);
    
    NSString *cipherResult = nil;
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t bufferSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCKeySizeDES,
                                          iv,
                                          plainStr.UTF8String,
                                          [plainStr dataUsingEncoding:NSUTF8StringEncoding].length, //plainStr.Length,
                                          buffer,
                                          1024,
                                          &bufferSize);
    if (cryptStatus == kCCSuccess)
    {
        NSLog(@"des加密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)bufferSize];
        
//        cipherResult = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];  // base64加密  （ios7以下使用data.base64Encoding）
//        cipherResult = [[cipherResult stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];  // 系统base64方法在有中文时会生成\r\n等 （或者自己写base64加密解密）
        
        cipherResult = [self convertDataToHexStr:data];  // 转化为16进制
    }
    return cipherResult;
}

// des解密
- (NSString *)desDecrypt:(NSString *)cipherStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    const char *keyChar = keyData.bytes;
    Byte *keyBytes = (Byte *)keyChar;
    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    Byte *ivBytes = (Byte *)ivData.bytes;
    
    NSString *plainResult = nil;
    
//    // base64
//    NSData *cipherData_UnBase64 = [[NSData alloc] initWithBase64EncodedString:cipherStr options:0];  // base64解密 （ios7以下使用[[NSData alloc] initWithBase64Encoding:cipherStr]）
//    const char *cipherBytes = cipherData_UnBase64.bytes;
//    NSUInteger cipherLength = cipherData_UnBase64.length;
    
    // 16进制转回data
    NSData *cipherData = [self convertHexStrToData:cipherStr];
    const char *cipherBytes = cipherData.bytes;
    NSUInteger cipherLength = cipherData.length;
    
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t bufferSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          keyBytes,
                                          kCCKeySizeDES,
                                          ivBytes,
                                          cipherBytes,
                                          cipherLength,
                                          buffer,
                                          1024,
                                          &bufferSize);
    if (cryptStatus == kCCSuccess)
    {
        NSLog(@"des解密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)bufferSize];
        plainResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainResult;
}


// data(byte)转化为16进制字符串
- (NSString *)convertDataToHexStr:(NSData *)data
{
    Byte *bytes = (Byte *)data.bytes;
    NSMutableString *hexStr = [[NSMutableString alloc] init];
    for(int i=0; i<data.length; i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff];  // 16进制数
        if(newHexStr.length == 1)
        {
            [hexStr appendFormat:@"0%@", newHexStr];
        }
        else
        {
            [hexStr appendFormat:@"%@", newHexStr];
        }
    }
    return hexStr;
}

// 16进制字符串转回data
- (NSData *)convertHexStrToData:(NSString *)hexStr
{
    char *myBuffer = (char *)malloc((int)hexStr.length / 2 + 1);
    bzero(myBuffer, hexStr.length / 2 + 1);
    for (int i = 0; i < hexStr.length - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSData *data = [NSData dataWithBytes:myBuffer length:strlen(myBuffer)];
    free(myBuffer);  // malloc和free需成对使用
    return data;
}




- (NSString *)cryptor:(NSString *)sourceStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr operation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm size:(size_t)keySize
{
    NSString *resultStr = nil;
    
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *sourceData = nil;
    if (operation == kCCEncrypt)  // 加密
    {
        sourceData = [sourceStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if (operation == kCCDecrypt)  // 解密
    {
//        sourceData = [self convertHexStrToData:sourceStr];  // 若加密时使用16进制字符串，此处解密时需先从16进制转回data
        sourceData = [[NSData alloc] initWithBase64EncodedString:sourceStr options:0];  // 若加密时使用base64，此处解密时需先base64解密 （ios7以下使用[[NSData alloc] initWithBase64Encoding:sourceStr]）
    }
    
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t bufferSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,              // kCCEncrypt || kCCDecrypt
                                          algorithm,              // kCCAlgorithmAES(128) || kCCAlgorithmDES
                                          kCCOptionPKCS7Padding,
                                          keyData.bytes,          // 密钥
                                          keySize,                // kCCKeySizeAES128 || kCCKeySizeDES
                                          ivData.bytes,           // 偏移向量
                                          sourceData.bytes,
                                          sourceData.length,
                                          buffer,
                                          1024,
                                          &bufferSize);
    if (cryptStatus == kCCSuccess)
    {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)bufferSize];
        if (operation == kCCEncrypt)  // 加密
        {
//            resultStr = [self convertDataToHexStr:data];  // 转化为16进制字符串
            
            resultStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];  // base64再次加密  （ios7以下使用data.base64Encoding）
            resultStr = [[resultStr stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];  // 系统base64方法在有中文时会生成\r\n等，需去掉，否则解密不成功 （或者自己写base64加密解密）
        }
        else if (operation == kCCDecrypt)  // 解密
        {
            resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return resultStr;
}

// des加密
- (NSString *)kk_desEncrypt:(NSString *)plainStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    return [self cryptor:plainStr key:keyStr iv:ivStr operation:kCCEncrypt algorithm:kCCAlgorithmDES size:kCCKeySizeDES];
}

// des解密
- (NSString *)kk_desDecrypt:(NSString *)cipherStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    return [self cryptor:cipherStr key:keyStr iv:ivStr operation:kCCDecrypt algorithm:kCCAlgorithmDES size:kCCKeySizeDES];
}

// aes加密
- (NSString *)kk_aesEncrypt:(NSString *)plainStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    return [self cryptor:plainStr key:keyStr iv:ivStr operation:kCCEncrypt algorithm:kCCAlgorithmAES size:kCCKeySizeAES128];
}

// aes解密
- (NSString *)kk_aesDecrypt:(NSString *)cipherStr key:(NSString *)keyStr iv:(nullable NSString *)ivStr
{
    return [self cryptor:cipherStr key:keyStr iv:ivStr operation:kCCDecrypt algorithm:kCCAlgorithmAES size:kCCKeySizeAES128];
}


@end
