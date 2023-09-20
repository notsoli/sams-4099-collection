@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(7) var<storage> a: array<f32>;
@group(0) @binding(9) var<storage> b: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  // calculate normalized x position
  let xpos = pos.x / res.x;

  let idx = u32((pos.y * res.x + pos.x - res.x / 2.) % (res.x * res.y));
  let v = a[idx];
  let w = b[idx];

  // raw diffusion value
  let diff = clamp(0., 1., v - w);

  // create a gradient that depends on x position
  let g1 = vec3(1.,0.847,0.608);
  let g2 = vec3(0.098,0.329,0.482);
  let grad = mix(g1, g2, xpos);

  // mix gradient with white based on diffusion value
  let c = mix(grad, vec3(1., 1., 1.), diff);

  return vec4f(c, 1.);

}