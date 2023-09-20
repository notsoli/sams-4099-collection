@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<uniform> mouse_pos: vec2f;
@group(0) @binding(2) var<uniform> time_since_click: f32;
@group(0) @binding(3) var<uniform> D_A: f32;
@group(0) @binding(4) var<uniform> D_B: f32;
@group(0) @binding(5) var<uniform> F: f32;
@group(0) @binding(6) var<uniform> K: f32;
@group(0) @binding(7) var<storage, read_write> a_in: array<f32>;
@group(0) @binding(8) var<storage, read_write> a_out: array<f32>;
@group(0) @binding(9) var<storage, read_write> b_in: array<f32>;
@group(0) @binding(10) var<storage, read_write> b_out: array<f32>;

// reminder: CenterWeight * 4(AdjacentWeight) + 4(DiagonalWeight) must equal 0
const CenterWeight = -1.0;
const AdjacentWeight = 0.2;
const DiagonalWeight = 0.05;

fn calc_idx(cell : vec3i, x : i32, y : i32) -> i32 {
  return (cell.y + y) * i32(res.x) + cell.x + x;
}

fn laplace_a(cell : vec3i) -> f32 {
  var total = 0.;
  total += a_in[calc_idx(cell, 0, 0)] * CenterWeight;
  total += a_in[calc_idx(cell, -1, 0)] * AdjacentWeight;
  total += a_in[calc_idx(cell, 1, 0)] * AdjacentWeight;
  total += a_in[calc_idx(cell, 0, -1)] * AdjacentWeight;
  total += a_in[calc_idx(cell, 0, 1)] * AdjacentWeight;
  total += a_in[calc_idx(cell, -1, -1)] * DiagonalWeight;
  total += a_in[calc_idx(cell, 1, -1)] * DiagonalWeight;
  total += a_in[calc_idx(cell, -1, 1)] * DiagonalWeight;
  total += a_in[calc_idx(cell, 1, 1)] * DiagonalWeight;
  return total;
}

fn laplace_b(cell : vec3i) -> f32 {
  var total = 0.;
  total += b_in[calc_idx(cell, 0, 0)] * CenterWeight;
  total += b_in[calc_idx(cell, -1, 0)] * AdjacentWeight;
  total += b_in[calc_idx(cell, 1, 0)] * AdjacentWeight;
  total += b_in[calc_idx(cell, 0, -1)] * AdjacentWeight;
  total += b_in[calc_idx(cell, 0, 1)] * AdjacentWeight;
  total += b_in[calc_idx(cell, -1, -1)] * DiagonalWeight;
  total += b_in[calc_idx(cell, 1, -1)] * DiagonalWeight;
  total += b_in[calc_idx(cell, -1, 1)] * DiagonalWeight;
  total += b_in[calc_idx(cell, 1, 1)] * DiagonalWeight;
  return total;
}

@compute @workgroup_size(8,8)

fn cs(@builtin(global_invocation_id) _cell:vec3u)  {
  let cell = vec3i(_cell);
  let dist = distance(vec3f(cell).xy, mouse_pos);

  // prevent laplace function from being run on the edges of the screen
  if (cell.x == 0 || cell.x == i32(res.x) - 1 ||
      cell.y == 0 || cell.y == i32(res.y) - 1) { return; }

  let idx = calc_idx(cell, 0, 0);
  let A = a_in[idx];
  let B = b_in[idx];

  let K_Adjusted = mix(K - 0.002, K + 0.002, f32(cell.x) / res.x);

  a_out[idx] = A + D_A * laplace_a(cell) - A * B * B + F * (1. - A);
  b_out[idx] = B + D_B * laplace_b(cell) + A * B * B - (K_Adjusted + F) * B;

  if (time_since_click < 1.) {
    let dist = distance(vec3f(cell).xy, mouse_pos);
    if (dist < 50.) {
      a_out[idx] = 0.;
      b_out[idx] = 1.;
    }
  }
}