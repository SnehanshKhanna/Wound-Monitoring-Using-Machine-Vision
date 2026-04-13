import tensorflow as tf
from tensorflow.keras import layers, Model

def build_unet(input_shape=(256,256,3)):

    inputs = layers.Input(input_shape)

    # Encoder
    c1 = layers.Conv2D(32,3,activation='relu',padding='same')(inputs)
    p1 = layers.MaxPooling2D()(c1)

    c2 = layers.Conv2D(64,3,activation='relu',padding='same')(p1)
    p2 = layers.MaxPooling2D()(c2)

    # Bottleneck
    b = layers.Conv2D(128,3,activation='relu',padding='same')(p2)

    # Decoder
    u1 = layers.UpSampling2D()(b)
    c3 = layers.Conv2D(64,3,activation='relu',padding='same')(u1)

    u2 = layers.UpSampling2D()(c3)
    c4 = layers.Conv2D(32,3,activation='relu',padding='same')(u2)

    outputs = layers.Conv2D(1,1,activation='sigmoid')(c4)

    return Model(inputs, outputs)