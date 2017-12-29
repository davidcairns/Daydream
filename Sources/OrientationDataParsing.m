//
//  OrientationDataParsing.m
//  DaydreamSample
//
//  Created by David Cairns on 12/26/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "OrientationDataParsing.h"

int MagnetometerXFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int xOri = (bytes[1] & 0x03) << 11 | (bytes[2] & 0xFF) << 3 | (bytes[3] & 0x80) >> 5;
    return (xOri << 19) >> 19;
}
int MagnetometerYFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int yOri = (bytes[3] & 0x1F) << 8 | (bytes[4] & 0xFF);
    return (yOri << 19) >> 19;
}
int MagnetometerZFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int zOri = (bytes[5] & 0xFF) << 5 | (bytes[6] & 0xF8) >> 3;
    return (zOri << 19) >> 19;
}

int AccelerationXFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int xAcc = (bytes[6] & 0x07) << 10 | (bytes[7] & 0xFF) << 2 | (bytes[8] & 0xC0) >> 6;
    return (xAcc << 19) >> 19;
}
int AccelerationYFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int yAcc = (bytes[8] & 0x3F) << 7 | (bytes[9] & 0xFE) >> 1;
    return (yAcc << 19) >> 19;
}
int AccelerationZFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int zAcc = (bytes[9] & 0x01) << 12 | (bytes[10] & 0xFF) << 4 | (bytes[11] & 0xF0) >> 4;
    return (zAcc << 19) >> 19;
}

int GyroXFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int xGyro = ((bytes[11] & 0x0F) << 9 | (bytes[12] & 0xFF) << 1 | (bytes[13] & 0x80) >> 7);
    return (xGyro << 19) >> 19;
}
int GyroYFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int yGyro = ((bytes[13] & 0x7F) << 6 | (bytes[14] & 0xFC) >> 2 );
    return (yGyro << 19) >> 19;
}
int GyroZFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    int zGyro = ((bytes[14] & 0x03) << 11 | (bytes[15] & 0xFF) << 3 | (bytes[16] & 0xE0) >> 5);
    return (zGyro << 19) >> 19;
}

CMAcceleration DCMakeVec3(double x, double y, double z) {
    CMAcceleration v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

CMAcceleration DCVec3Normalize(CMAcceleration v) {
    const double magnitude = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    if (magnitude < 0.000001) {
        return DCMakeVec3(0.0, 0.0, 0.0);
    }
    return DCMakeVec3(v.x / magnitude, v.y / magnitude, v.z / magnitude);
}


CMAcceleration AdjustedMagnetometerFromData(NSData *data) {
    const double orientationScale = 2 * M_PI / 4095.0;
    return DCMakeVec3(orientationScale * MagnetometerXFromData(data),
                      orientationScale * MagnetometerYFromData(data),
                      orientationScale * MagnetometerZFromData(data));
}
CMAcceleration AdjustedAccelerometerFromData(NSData *data) {
    const double accelerationScale = 8 * 9.8 / 4095.0;
    return DCVec3Normalize(DCMakeVec3(accelerationScale * AccelerationXFromData(data),
                                      accelerationScale * AccelerationYFromData(data),
                                      accelerationScale * AccelerationZFromData(data)));
}
CMAcceleration AdjustedGyroFromData(NSData *data) {
    const double gyroScale = 2048 / 180 * M_PI / 4095.0;
    return DCMakeVec3(gyroScale * GyroXFromData(data),
                      gyroScale * GyroYFromData(data),
                      gyroScale * GyroZFromData(data));
}


// MARK: - 
double TouchPointX(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    return ((bytes[16] & 0x1F) << 3 | (bytes[17] & 0xE0) >> 5) / 255.0;
}
double TouchPointY(NSData *data) {
    uint8_t *const bytes = (uint8_t *)data.bytes;
    return ((bytes[17] & 0x1F) << 3 | (bytes[18] & 0xE0) >> 5) / 255.0;
}
