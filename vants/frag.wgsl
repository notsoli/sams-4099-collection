struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
}

struct Vant {
  pos: vec2f,
  dir: f32,
  flag: f32
}

@group(0) @binding(0) var<uniform> grid_size: f32;
@group(0) @binding(1) var<uniform> res: vec2f;
@group(0) @binding(2) var<uniform> blast_radius: f32;
@group(0) @binding(3) var<storage> vants: array<Vant>;
@group(0) @binding(4) var<storage> pheromones: array<f32>;
@group(0) @binding(5) var<storage> render: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let grid_pos = floor( pos.xy / grid_size);
  
  let field = round(res / grid_size);
  let pidx = grid_pos.y  * field.x + grid_pos.x;
  let p = pheromones[ u32(pidx) ];
  let v = render[ u32(pidx) ];

  var out = vec3(0.114,0.118,0.122);

  // initially set to white if pheromone is present
  if (p == 1.) {
    out = vec3(0.192,0.2,0.212);
  } else if (p == 0.5) {
    out = vec3(0.631,0.263,0.357);
  }

  if (v == 1.) {
    out = vec3(0.071,0.761,0.914);
  } else if (v == 2.) {
    out = vec3(0.769,0.443,0.929);
  } else if (v == 3.) {
    out = vec3(0.965,0.31,0.349);
  }
  
  return vec4f( out, 1. );
}