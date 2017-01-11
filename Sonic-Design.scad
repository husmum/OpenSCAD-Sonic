/*Hussain Mumtaz
husmum@gatech.edu
*/

BLACK = "Black";
BLUE = [.31, .45, .69];
WHITE = "White";
SKIN = [.90,.596,.41];
LIME_GREEN = "LimeGreen";

Y_90_DEGREES = [0,90,0];
RIGHT_15_DEGREES = [15, 0, 0];
LEFT_15_DEGREES = [-15, 0, 0];

DIRECTIONS = [-1, 1];

ARRAY_BASE_CORRECTION = -1;

function array_range(array) = [0:len(array) + ARRAY_BASE_CORRECTION];

module pedestal() {
    offset = [-6, 0, -20];
    height = 2;
    radius = 32;

    color(BLACK)
        translate(offset)
            cylinder(h = height, r = radius);
}

module eye_orbits(offset_x) {
    orbit_deviation = 8;
    offset_z = 4;
    radius = 5;

    for (i = array_range(DIRECTIONS)) {
        translate([offset_x, orbit_deviation * DIRECTIONS[i], offset_z])
            sphere(r = radius);
    }
}

module head() {
    offset_x = 15;
    radius = 20;
    color(BLUE)
        difference() {
                sphere(r = radius);
            hull()
                eye_orbits(offset_x);
        }
}

module scleras() {
    offset_x = 14;

    color(WHITE)
        difference()
            hull()
                eye_orbits(offset_x);
}

module eye_detail(color, offset, scale, radius) {
    color(color)
        translate(offset)
            scale(scale)
                sphere(r = radius);
}

module iris(offset_y) {
    offset = [18.3, offset_y, 4];
    scale = [2, 2, 3];
    radius = 1;

    eye_detail(LIME_GREEN, offset, scale, radius);
}

module pupil(offset_y) {
    offset = [19.6, offset_y, 3];
    scale = [1, 1, 2];
    radius= 1;

    eye_detail(BLACK, offset, scale, radius);
}

module brightness(offset_y) {
    center_deviation = 0.2;
    offset = [20.1, offset_y - center_deviation, 2];
    scale = [1, 1, 1];
    radius = 0.4;

    eye_detail(WHITE, offset, radius);
}

module eyes() {
    offset = 7;

    scleras();

    for (i = array_range(DIRECTIONS)) {
        offset_y = DIRECTIONS[i] * offset;
        iris(offset_y);
        pupil(offset_y);
        brightness(offset_y);
    }
}

module lock_of_hair(lock){
    iterations = 25;
    segment_height = 5;

    for (i = [0:iterations]) {
        rotation = [0, 90 - i, 0];
        offset_x = lock[0] - i / iterations;
        offset_y = lock[1];
        offset_z = lock[2] - i;
        radius = 8 - i/3.125;

        color(BLUE)
            rotate(rotation)
                translate([offset_x, offset_y, offset_z])
                    cylinder(h = segment_height, r = radius);
    }
}

module hair() {
    offset_z = -8;
    locks_offsets = [
        [-12, 0, offset_z],
        [-5, 8, offset_z],
        [-5, -8, offset_z],
        [5, 8, offset_z],
        [5, -8, offset_z],
        [0, 0, offset_z]
    ];

    for (i = array_range(locks_offsets)) {
        lock_of_hair(locks_offsets[i]);
    }
}

module nose_base() {
    internal_part_radius = 2;
    external_part_radius = 2.4;
    external_part_offset = [2, 0, 0];

    color(BLACK)
        hull(){
            sphere(r = internal_part_radius);

            translate(external_part_offset)
                sphere(r = external_part_radius);
        }
}

module nose_substractions(position) {
    offset_x = 1;
    offset_y = 0;
    offset_z = 3;
    radius = 2;

    for (i = array_range(DIRECTIONS)) {
        color(BLACK)
            translate([offset_x, offset_y, offset_z * DIRECTIONS[i]])
                sphere(r = radius);
    }
}

module nose() {
    offset = [20, 0, 0];

    translate(offset)
        difference() {
            nose_base();
            nose_substractions();
        }
}

module smirk_stroke(rotation, ratio, offsets) {
    radius = 1;

    rotate(rotation)
        difference() {
            translate(offsets[0])
                scale(ratio)
                    sphere(r = radius);

            translate(offsets[1])
                scale(ratio)
                    sphere(r = radius);
        }
}

function stroke(rotation, scale, offsets) = [rotation, ratio, offsets];

module smirk() {
    offset = [20, 3, -7];

    strokes = [
        stroke(
            rotation = RIGHT_15_DEGREES,
            ratio = [1, 4, 1],
            offsets = [
                [ 0, 0, 0],
                [ 0, 0, 1]
            ]
        ),
        stroke(
            rotation = LEFT_15_DEGREES,
            ratio = [1, 1, 4],
            offsets = [
                [0, 3, 2],
                [ 0, 3, 0]
            ]
        ),
        stroke(
            rotation = RIGHT_15_DEGREES,
            ratio = [1, 1, 4],
            offsets = [
                [0, 3.5, 0],
                [0, 3.5, 2]
            ]
        )
    ];

    color(BLACK)
        translate(offset) {
            for (i = array_range(strokes)) {
                smirk_stroke(
                    rotation = strokes[i][0],
                    ratio = strokes[i][1],
                    offsets = strokes[i][2]
                );
            }
        }
}

function invert_y(xyz) = [xyz[0], xyz[1] * -1, xyz[2]];

module snout() {
    offset = [7, 0, 0];
    base_radius = 15;
    base_substraction_radius = 13.5;
    front_substraction_offset = [-15, -15, -15];
    front_substraction_dimensions = [15, 30, 30];
    side_substraction_offset = [8, -7.5, 6];
    side_substraction_radius = 9;
    nose_contour_offset = [15, 0, 2];
    nose_contour_radius = 4;

    color(SKIN)
        translate(offset)
            difference() {

                sphere(base_radius);
                sphere(base_substraction_radius);

                rotate(Y_90_DEGREES)
                    translate(front_substraction_offset)
                        cube(front_substraction_dimensions);

                translate(side_substraction_offset)
                    sphere(side_substraction_radius);

                translate(invert_y(side_substraction_offset))
                    sphere(side_substraction_radius);

               translate(nose_contour_offset)
                    sphere(nose_contour_radius);
            }
}

module outer_ear(pavilion) {
    base_height = 10;
    base_bottom_radius = 5;
    base_top_radius = 0;

    substraction_offset = [0, -5, 0];
    substraction_size = 10;

    color(BLUE)
        difference() {
            cylinder(base_height, base_bottom_radius, base_top_radius);
            cylinder(pavilion[0], pavilion[1], pavilion[2]);

            translate(substraction_offset)
                cube(substraction_size);
    }
}

module inner_ear(pavilion) {
    substraction_size = 8;
    substraction_offset = [0, -4, 0];

    color(SKIN)
        difference() {
            cylinder(pavilion[0], pavilion[1], pavilion[2]);

            translate(substraction_offset)
                cube(substraction_size);
    }
}

module ear(offset_y, rotation_x) {
    offset = [5, offset_y, 16];
    rotation = [rotation_x, 0, 0];
    pavilion_height = 6;
    pavilion_bottom_radius = 4;
    pavilion_top_radius = 0;
    pavilion = [
        pavilion_height,
        pavilion_bottom_radius,
        pavilion_top_radius
    ];

    translate(offset)
        rotate(rotation) {
            outer_ear(pavilion);
            inner_ear(pavilion);
        }
}

module ears() {
    offset_y = -10;
    rotation_x = 25;

    for (i = array_range(DIRECTIONS)) {
        ear(offset_y * DIRECTIONS[i], rotation_x * DIRECTIONS[i]);
    }
}

module sonic() {
    pedestal();
    head();
    eyes();
    hair();
    nose();
    smirk();
    snout();
    ears();
}

sonic();
