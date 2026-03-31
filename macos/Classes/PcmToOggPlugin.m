#import "PcmToOggPlugin.h"
#import "pcm_to_ogg_native.h"

@implementation PcmToOggPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"pcm_to_ogg"
                                    binaryMessenger:[registrar messenger]];
    PcmToOggPlugin *instance = [[PcmToOggPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
        result(nil);
    } else if ([@"convert" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        FlutterStandardTypedData *pcmDataTyped = args[@"pcmData"];
        NSNumber *channelsNum = args[@"channels"];
        NSNumber *sampleRateNum = args[@"sampleRate"];
        NSNumber *qualityNum = args[@"quality"];

        if (!pcmDataTyped || !channelsNum || !sampleRateNum || !qualityNum) {
            result([FlutterError errorWithCode:@"INVALID_ARGUMENTS"
                                       message:@"Missing or invalid arguments for convert"
                                       details:nil]);
            return;
        }

        NSData *pcmData = pcmDataTyped.data;
        int numSamples = (int)(pcmData.length / 4);
        int channels = [channelsNum intValue];
        long sampleRate = [sampleRateNum longValue];
        float quality = [qualityNum floatValue];

        float *pcmFloatPtr = (float *)[pcmData bytes];

        void *oggOutputPointer = encode_pcm_to_ogg(
            pcmFloatPtr,
            (long)numSamples,
            channels,
            sampleRate,
            quality
        );

        if (oggOutputPointer) {
            OggOutput *oggPtr = (OggOutput *)oggOutputPointer;
            unsigned char *dataPtr = get_ogg_output_data(oggPtr);

            if (!dataPtr) {
                result([FlutterError errorWithCode:@"CONVERSION_FAILED"
                                           message:@"C function returned null data pointer"
                                           details:nil]);
                free_ogg_output(oggPtr);
                return;
            }

            int dataSize = get_ogg_output_size(oggPtr);
            NSData *oggData = [NSData dataWithBytes:dataPtr length:dataSize];

            free_ogg_output(oggPtr);

            result([FlutterStandardTypedData typedDataWithBytes:oggData]);
        } else {
            result([FlutterError errorWithCode:@"CONVERSION_FAILED"
                                       message:@"C function encode_pcm_to_ogg returned null"
                                       details:nil]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
