//
//  Vect3.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

typedef struct Vect3 {
    double x, y, z;
} Vect3;

Vect3 Vect3Make(double x, double y, double z);

double Vect3Magnitude(Vect3 v);
Vect3 Vect3Normalize(Vect3 v);

double Vect3Dot(Vect3 u, Vect3 v);
Vect3 Vect3Cross(Vect3 u, Vect3 v);
