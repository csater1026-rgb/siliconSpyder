// ============================================================================
// Silicon Spyder — Secure WiFi Box Enclosure
// Parametric 3-tier case: base (electronics) / chamber (cooling) / tray+cover
// (router). Non-metal only — this is meant to be 3D-printed (PETG or ABS
// recommended over PLA for the heat near the router/fans). Metal blocks WiFi.
//
// HOW TO USE: set `part` below to the piece you want, then render (F6) and
// export as STL (F7 in the OpenSCAD GUI, or see the command-line examples
// at the bottom of this file). Print one part at a time.
//
// Units: mm throughout.
// ============================================================================

part = "all"; // "base" | "chamber" | "tray" | "cover" | "all" (all = assembly preview only, do not print "all")

/* [Router — TP-Link Archer AX21 (AX1800)] */
router_w = 261;   // long axis
router_d = 135;
router_h = 39;

/* [Footprint geometry] */
// The router's long (261mm) sides are cradled snugly by thin walls.
// The router's 135mm depth is shorter than the module, so front/back voids
// are left over — those voids are the internal cable chase (router power +
// Ethernet routed straight down to the Pi) and the carry-handle cutouts.
cradle_wall  = 6;     // wall hugging the router's long sides
side_void    = 22.5;  // front/back void depth (cable chase + handles)

footprint_w = router_w + 2*cradle_wall;  // = 273mm, matches the brief's target footprint
footprint_d = router_d + 2*side_void;    // = 180mm, matches the brief's target footprint
// NOTE: 22.5mm of void is what actually makes the cable chase + handle
// cutouts functional (enough room for an RJ45 + DC barrel plug side by
// side). A tighter void looks fine on paper but won't fit real cables.

/* [Shared shell] */
wall_t  = 3;     // wall thickness (2-3 perimeters on most FDM printers)
floor_t = 3;

/* [Corner posts — one M3 screw runs through all 4 tiers into a captured nut in the base] */
post_d      = 9;      // corner post outer diameter
screw_d     = 3.4;    // M3 clearance hole (through cover/tray/chamber/base)
post_inset  = 8;       // post center inset from each footprint edge
m3_nut_af   = 5.6;     // M3 hex nut across-flats, +clearance
m3_nut_h    = 2.8;     // M3 hex nut thickness, +clearance

/* [Tier heights] */
base_h    = 45;              // electronics tier: clears Pi4 + SIM7600G-H HAT stack + antenna connectors
chamber_h = 30;               // cooling tier
tray_h    = router_h + 4;     // router tier: snug over the router's 39mm height
cover_t   = 3;

/* [Venting] */
vent_w        = 4;     // slot width
vent_len_frac = 0.7;    // fraction of a wall's length used for its vent field, centered

/* [Fans — 2x 40mm, mounted in the chamber floor blowing upward] */
fan_size         = 40;
fan_hole_pattern = 32;
fan_bore         = 38;
fan_count        = 2;
fan_screw_d      = 3.2;

/* [Raspberry Pi 4 — real board 85x56mm, M2.5 holes on a 58x49mm pattern] */
pi_w             = 85;
pi_d             = 56;
pi_hole_dx       = 58;
pi_hole_dy       = 49;
pi_hole_inset_x  = 3.5;   // hole inset from board edge (both axes)
pi_standoff_d    = 6;
pi_standoff_h    = 8;      // clears the underside of the board + any bottom components
pi_mount_hole_d  = 2.6;    // self-taps for M2.5

/* [Antenna panel mounts — SMA, on the base's short end walls] */
// Cellular + GNSS (SIM7600G-H) on one end, the Alfa/MT7921 monitor adapter's
// antenna on the other. Adjust sma_positions below once you've test-fit the
// real cable ends.
sma_hole_d = 6.5;

$fn = 48;

// ============================================================================
// Helpers
// ============================================================================

function corner_positions() = [
  [post_inset, post_inset],
  [footprint_w - post_inset, post_inset],
  [post_inset, footprint_d - post_inset],
  [footprint_w - post_inset, footprint_d - post_inset],
];

// A corner post with a through-hole for the M3 assembly screw.
module corner_post(h) {
  difference() {
    cylinder(d = post_d, h = h);
    translate([0, 0, -0.5]) cylinder(d = screw_d, h = h + 1);
  }
}

module all_corner_posts(h) {
  for (p = corner_positions())
    translate([p[0], p[1], 0]) corner_post(h);
}

// Hex nut trap, opening downward from z=0 (used at the base's floor).
module nut_trap(h = m3_nut_h) {
  cylinder(d = m3_nut_af / cos(30), h = h, $fn = 6);
}

// A field of vertical slots cut along a wall of given length/height, meant to
// be translated+rotated into place by the caller. Slots run in Z, cut through Y.
module vent_field(wall_len, wall_h, n, z0 = 0) {
  usable = wall_len * vent_len_frac;
  start  = (wall_len - usable) / 2;
  pitch  = usable / n;
  slot_w = min(vent_w, pitch * 0.6);
  for (i = [0 : n - 1])
    translate([start + i * pitch + (pitch - slot_w) / 2, -1, z0])
      cube([slot_w, wall_t + 2, wall_h]);
}

// Generic open-top box shell: floor + 4 walls, wall thickness wall_t.
module shell(w, d, h, floor = true) {
  difference() {
    cube([w, d, h]);
    translate([wall_t, wall_t, floor ? floor_t : -1])
      cube([w - 2*wall_t, d - 2*wall_t, h - (floor ? floor_t : 0) + 1]);
  }
}

// ============================================================================
// BASE — electronics tier (Pi4 + SIM7600G-H HAT + Alfa adapter)
// Closed, vented box. SMA panel mounts on the short (footprint_d-facing) end
// walls. Nut traps at the 4 corner posts capture the single M3 assembly screw
// that runs up through chamber + tray + cover.
// ============================================================================
module base() {
  difference() {
    union() {
      shell(footprint_w, footprint_d, base_h);
      all_corner_posts(base_h);
    }

    // Intake venting on both long (front/back) walls, low down near the floor
    translate([0, 0, 0])
      vent_field(footprint_w, base_h * 0.5, 10, z0 = floor_t + 4);
    translate([0, footprint_d - wall_t, 0])
      vent_field(footprint_w, base_h * 0.5, 10, z0 = floor_t + 4);

    // SMA panel-mount holes on the two short end walls (cellular/GNSS one
    // side, Alfa monitor-adapter antenna the other). Two holes per end,
    // centered vertically, spread across the wall — nudge sma_hole_d /
    // positions once you've test-fit your actual pigtails.
    for (yz = [[footprint_d*0.35, base_h*0.55], [footprint_d*0.65, base_h*0.55]])
      translate([-1, yz[0], yz[1]])
        rotate([0, 90, 0])
          cylinder(d = sma_hole_d, h = wall_t + 2);
    for (yz = [[footprint_d*0.35, base_h*0.55], [footprint_d*0.65, base_h*0.55]])
      translate([footprint_w - wall_t - 1, yz[0], yz[1]])
        rotate([0, 90, 0])
          cylinder(d = sma_hole_d, h = wall_t + 2);

    // Nut traps for the assembly screws, opening from the floor underside
    for (p = corner_positions())
      translate([p[0], p[1], -0.5]) nut_trap();
  }

  // Pi4 mounting standoffs — real 58x49mm hole pattern, centered in the base
  pi_origin = [(footprint_w - pi_w)/2, (footprint_d - pi_d)/2];
  for (hx = [pi_hole_inset_x, pi_hole_inset_x + pi_hole_dx])
    for (hy = [pi_hole_inset_x, pi_hole_inset_x + pi_hole_dy])
      translate([pi_origin[0] + hx, pi_origin[1] + hy, floor_t])
        difference() {
          cylinder(d = pi_standoff_d, h = pi_standoff_h);
          translate([0, 0, -0.5]) cylinder(d = pi_mount_hole_d, h = pi_standoff_h + 1);
        }
}

// ============================================================================
// CHAMBER — cooling tier
// Fully enclosed except vents on both long walls; 2x 40mm fans mounted in the
// floor, blowing upward (pulling intake air from the base below and the side
// vents, exhausting up through the open-floor tray and out the vented cover).
// Top and bottom are open — the corner posts + adjoining tiers close the box.
// ============================================================================
module chamber() {
  difference() {
    union() {
      // side walls only (no floor/ceiling plate — open top & bottom)
      difference() {
        cube([footprint_w, footprint_d, chamber_h]);
        translate([wall_t, wall_t, -1])
          cube([footprint_w - 2*wall_t, footprint_d - 2*wall_t, chamber_h + 2]);
      }
      all_corner_posts(chamber_h);

      // solid fan-mounting shelf, low in the chamber (fan bores + screw
      // holes are cut through it separately by chamber_fan_cuts())
      cube([footprint_w, footprint_d, floor_t]);
    }

    // vents on both long walls, upper half (above the fan shelf)
    translate([0, 0, 0])
      vent_field(footprint_w, chamber_h * 0.6, 10, z0 = floor_t + 6);
    translate([0, footprint_d - wall_t, 0])
      vent_field(footprint_w, chamber_h * 0.6, 10, z0 = floor_t + 6);
  }
}

module chamber_fan_cuts() {
  fan_y  = footprint_d / 2;
  fan_xs = fan_count == 2
    ? [footprint_w/2 - fan_size*0.6, footprint_w/2 + fan_size*0.6]
    : [footprint_w/2];
  for (fx = fan_xs) {
    translate([fx, fan_y, -0.5]) cylinder(d = fan_bore, h = floor_t + 2);
    for (cxy = [[1,1], [1,-1], [-1,1], [-1,-1]])
      translate([fx + cxy[0]*fan_hole_pattern/2, fan_y + cxy[1]*fan_hole_pattern/2, -0.5])
        cylinder(d = fan_screw_d, h = floor_t + 2);
  }
}

// ============================================================================
// TRAY — router tier
// Side walls cradle the router snugly on its long sides; open floor (so the
// chamber's fan airflow reaches the router's underside) and open top (closed
// separately by the vented cover). Front/back voids beside the router are the
// cable chase + carry-handle cutouts.
// ============================================================================
module tray() {
  handle_w = 70;
  handle_h = 14;

  difference() {
    union() {
      // cradle walls on the long sides only (no front/back walls — those are
      // the open cable-chase/handle voids)
      translate([0, 0, 0]) cube([cradle_wall, footprint_d, tray_h]);
      translate([footprint_w - cradle_wall, 0, 0]) cube([cradle_wall, footprint_d, tray_h]);
      all_corner_posts(tray_h);

      // thin front/back lips just enough to carry the corner posts, leaving
      // the rest of the void open for cables + hands
      translate([0, 0, 0]) cube([footprint_w, wall_t, tray_h]);
      translate([0, footprint_d - wall_t, 0]) cube([footprint_w, wall_t, tray_h]);
    }

    // carry-handle cutouts, centered in each void
    translate([footprint_w/2 - handle_w/2, -1, tray_h/2 - handle_h/2])
      cube([handle_w, side_void + wall_t + 2, handle_h]);
    translate([footprint_w/2 - handle_w/2, footprint_d - side_void - wall_t - 1, tray_h/2 - handle_h/2])
      cube([handle_w, side_void + wall_t + 2, handle_h]);
  }
}

// ============================================================================
// COVER — vented top
// Flat plate over the router tier: vent slots (not sealed) so heat escapes
// upward, plus 4 antenna pass-through holes. Screws down onto the same 4
// corner posts as everything else. Antenna positions are evenly spaced
// placeholders — nudge them to match your AX21's real antenna spacing once
// you have it in hand.
// ============================================================================
module cover() {
  antenna_hole_d = 9;
  antenna_y = footprint_d / 2;
  antenna_xs = [
    footprint_w * 0.20, footprint_w * 0.38,
    footprint_w * 0.62, footprint_w * 0.80,
  ];

  difference() {
    cube([footprint_w, footprint_d, cover_t]);

    // vent slots, two rows (front half / back half of the router), skipping
    // a center band so antenna holes have solid material around them
    for (yfrac = [0.28, 0.72])
      translate([0, footprint_d * yfrac - vent_w/2, -0.5])
        rotate([0, 0, 0])
          for (i = [0:14])
            translate([footprint_w*0.08 + i*(footprint_w*0.84/15), 0, 0])
              cube([footprint_w*0.84/15*0.5, vent_w, cover_t + 1]);

    for (ax = antenna_xs)
      translate([ax, antenna_y, -0.5]) cylinder(d = antenna_hole_d, h = cover_t + 1);

    for (p = corner_positions())
      translate([p[0], p[1], -0.5]) cylinder(d = screw_d, h = cover_t + 1);
  }
}

// ============================================================================
// Assembly preview (NOT for printing — render one part at a time via `part`)
// ============================================================================
module assembly_preview() {
  color("SteelBlue") base();
  translate([0, 0, base_h]) difference() {
    color("LightSlateGray") chamber();
    chamber_fan_cuts();
  }
  translate([0, 0, base_h + chamber_h]) color("RoyalBlue") tray();
  translate([0, 0, base_h + chamber_h + tray_h]) color("DeepSkyBlue") cover();
}

// ============================================================================
// Dispatch
// ============================================================================
if (part == "base") base();
else if (part == "chamber") difference() { chamber(); chamber_fan_cuts(); }
else if (part == "tray") tray();
else if (part == "cover") cover();
else assembly_preview();

// ----------------------------------------------------------------------------
// Command-line export examples (from this directory):
//   openscad -D 'part="base"'    -o base.stl    silicon-spyder-enclosure.scad
//   openscad -D 'part="chamber"' -o chamber.stl silicon-spyder-enclosure.scad
//   openscad -D 'part="tray"'    -o tray.stl    silicon-spyder-enclosure.scad
//   openscad -D 'part="cover"'   -o cover.stl   silicon-spyder-enclosure.scad
// ----------------------------------------------------------------------------
