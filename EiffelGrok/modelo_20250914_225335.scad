// Eiffel Tower in OpenSCAD with medium-high detail for balance between detail and performance
// Units: meters
// For rendering, scale down, e.g., scale(0.01) eiffel_tower(); to make it smaller
// Segments: 100, braces every 2 levels, $fn=16 for smoother but not too high
// Removed joint spheres to save memory, using direct diagonals
// If still too slow, reduce N or increase brace_every

module line(start, end, diameter=1) {
  dir = end - start;
  len = norm(dir);
  if (len > 0) {
    axis = cross([0, 0, 1], dir / len);
    angle = acos(dir.z / len);
    translate(start)
      if (norm(axis) > 0) {
        rotate(angle, axis)
          cylinder(h=len, r=diameter/2, $fn=16);
      } else {
        cylinder(h=len, r=diameter/2, $fn=16);
      }
  }
}

r_outer_0 = 62.5; // half side at base
w0 = 12.5; // half pillar width at base
h = 300; // structural height
h1 = 57;
h2 = 115;
h3 = 276;
h4 = 300;
ratio1 = 31.5 / 62.5;
ratio2 = 18.5 / 31.5;
ratio3 = 8 / 18.5;
ratio4 = 0.5 / 8; // approximate to small at top

function half_side(z) =
  (z <= h1) ? r_outer_0 * pow(ratio1, z / h1) :
  (z <= h2) ? 31.5 * pow(ratio2, (z - h1) / (h2 - h1)) :
  (z <= h3) ? 18.5 * pow(ratio3, (z - h2) / (h3 - h2)) :
  8 * pow(ratio4, (z - h3) / (h4 - h3));

function w_leg_half(z) = w0 * (half_side(z) / r_outer_0);

function r_leg_center(z) = half_side(z) - w_leg_half(z);

N = 100; // medium segments for better detail
step = h / N;
beam_diam = 0.5; // main beam diameter
brace_diam = 0.3; // brace diameter
brace_every = 2; // braces every 2 segments for more detail

corners = [[1,1], [1,-1], [-1,1], [-1,-1]];

module eiffel_tower() {
  union() {
    // Main beams for the 4 legs' 4 beams each
    for (c = corners) {
      sx = c[0];
      sy = c[1];
      for (b = [[-1,-1], [-1,1], [1,-1], [1,1]]) {
        dx = b[0];
        dy = b[1];
        for (i = [0 : N-1]) {
          z1 = i * step;
          z2 = (i+1) * step;
          p1 = [sx * (r_leg_center(z1) + dx * w_leg_half(z1)),
                sy * (r_leg_center(z1) + dy * w_leg_half(z1)),
                z1];
          p2 = [sx * (r_leg_center(z2) + dx * w_leg_half(z2)),
                sy * (r_leg_center(z2) + dy * w_leg_half(z2)),
                z2];
          line(p1, p2, beam_diam);
        }
      }
    }

    // Braces within each leg: horizontal and diagonal at selected levels
    for (i = [0 : brace_every : N]) {
      z = i * step;
      for (c = corners) {
        sx = c[0];
        sy = c[1];
        points = [
          [sx * (r_leg_center(z) + -1 * w_leg_half(z)), sy * (r_leg_center(z) + -1 * w_leg_half(z)), z],
          [sx * (r_leg_center(z) + -1 * w_leg_half(z)), sy * (r_leg_center(z) + 1 * w_leg_half(z)), z],
          [sx * (r_leg_center(z) + 1 * w_leg_half(z)), sy * (r_leg_center(z) + -1 * w_leg_half(z)), z],
          [sx * (r_leg_center(z) + 1 * w_leg_half(z)), sy * (r_leg_center(z) + 1 * w_leg_half(z)), z]
        ];
        // Horizontal braces
        line(points[0], points[1], brace_diam);
        line(points[1], points[3], brace_diam);
        line(points[3], points[2], brace_diam);
        line(points[2], points[0], brace_diam);
        // Diagonal braces
        line(points[0], points[3], brace_diam);
        line(points[1], points[2], brace_diam);
      }
    }

    // Add cross braces between legs for additional detail (connecting adjacent legs at brace levels)
    for (i = [0 : brace_every : N]) {
      z = i * step;
      // Connect inner beams between adjacent corners
      for (j = [0:3]) {
        c1 = corners[j];
        c2 = corners[(j+1)%4];
        sx1 = c1[0]; sy1 = c1[1];
        sx2 = c2[0]; sy2 = c2[1];
        // Connect one inner point from each leg
        p1 = [sx1 * (r_leg_center(z) + -sx1 * w_leg_half(z)), sy1 * (r_leg_center(z) + -sy1 * w_leg_half(z)), z];
        p2 = [sx2 * (r_leg_center(z) + -sx2 * w_leg_half(z)), sy2 * (r_leg_center(z) + -sy2 * w_leg_half(z)), z];
        line(p1, p2, brace_diam);
      }
    }

    // Platforms (simplified as thin cubes)
    platform_thickness = 1;
    translate([0, 0, h1]) cube([2 * half_side(h1), 2 * half_side(h1), platform_thickness], center=true);
    translate([0, 0, h2]) cube([2 * half_side(h2), 2 * half_side(h2), platform_thickness], center=true);
    translate([0, 0, h3]) cube([2 * half_side(h3), 2 * half_side(h3), platform_thickness], center=true);

    // Top spire/antenna approximation
    antenna_h = 24; // to 324m
    translate([0, 0, h]) cylinder(h=antenna_h, r1=half_side(h), r2=0, $fn=16);
  }
}

eiffel_tower();
