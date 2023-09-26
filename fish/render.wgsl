struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
};

struct Particle {
  pos: vec2f,
  speed: f32,
  angle: f32
};

@group(0) @binding(1) var<uniform> fish_size: f32;
@group(0) @binding(2) var<uniform> res:   vec2f;
@group(0) @binding(3) var<storage> state: array<Particle>;

@vertex 
fn vs( input: VertexInput ) ->  @builtin(position) vec4f {
    var pos = input.pos;
    if (pos.y > 0.) { pos.x = 0.; }
    let size = pos * fish_size;
    let aspect = res.y / res.x;
    let p = state[ input.instance ];
    let size_rotated = vec2(
        size.x * cos(p.angle) - size.y * sin(p.angle),
        size.x * sin(p.angle) + size.y * cos(p.angle)
    );
    return vec4f( p.pos.x - size_rotated.x * aspect, p.pos.y + size_rotated.y, 0., 1.); 
}

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {;
  return vec4f( .8, .3, .3, .5);
}