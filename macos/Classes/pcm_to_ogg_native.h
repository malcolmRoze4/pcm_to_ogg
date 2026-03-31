#ifndef PCM_TO_OGG_NATIVE_H
#define PCM_TO_OGG_NATIVE_H

#include <stdint.h>

typedef struct {
    unsigned char* data;
    int size;
} OggOutput;

void* encode_pcm_to_ogg(
    float* pcm_data,
    long num_samples,
    int channels,
    long sample_rate,
    float quality
);

unsigned char* get_ogg_output_data(OggOutput* output);
int get_ogg_output_size(OggOutput* output);
void free_ogg_output(OggOutput* output);

#endif // PCM_TO_OGG_NATIVE_H
