@group(0) @binding(0) var<uniform> frame: f32;
@group(0) @binding(1) var<uniform> resolution: vec2f;
@group(0) @binding(2) var<uniform> click_pos: vec2f;
@group(0) @binding(3) var<uniform> time_since_click: f32;
@group(0) @binding(4) var<uniform> threshold: f32;
@group(0) @binding(5) var<uniform> noise_scale: f32;
@group(0) @binding(8) var videoSampler: sampler;
@group(1) @binding(0) var videoBuffer: texture_external;

const peek_scale = 150.;

// grab a determinstic random point based on grid position
fn get_point(grid_pos : vec2f) -> vec2f {
    let random = fract(sin(dot(grid_pos.xy,vec2(12.9898,78.233)))*43758.5453123);
    let val = (random - 0.5) * frame/10. + random * 6.283;
    return vec2(sin(val + 0.1), cos(val + random)) / 2. + 0.5;
}

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
    // get a scaled uv position
    let position = pos.xy / resolution;
    var pos_scaled = vec2(position.x * noise_scale * (resolution.x / resolution.y), position.y * noise_scale);

    // create grid of cells
    let grid_pos = floor(pos_scaled);
    let frac_pos = fract(pos_scaled);

    // generate voronoi noise
    var voronoi_value = distance(get_point(grid_pos), frac_pos);
    for (var y = -1; y <= 1; y++) {
        for (var x = -1; x <= 1; x++) {
            let neighbor_grid_pos = vec2(f32(x), f32(y));
            let neighbor_point = get_point(grid_pos + neighbor_grid_pos);
            let dist = distance(neighbor_grid_pos + neighbor_point, frac_pos);
            voronoi_value = min(dist, voronoi_value);
        }
    }
    var voronoi_color = mix(vec3(0.851,0.424,0.455), vec3(0.922,0.769,0.663), voronoi_value);

    // sample video
    let video = textureSampleBaseClampToEdge( videoBuffer, videoSampler, position);

    // mix video and voronoi based on brightness
    let avg = (video.r + video.g + video.b) / 3.;
    var out = voronoi_color;
    if (avg <= threshold) { out = video.rgb; }

    // allow video to show through on click
    let color_multiplier = clamp(1.2 - distance(pos.xy, click_pos) / peek_scale - time_since_click / 60., 0., 1.);
    let color_mix = mix(out, video.rgb, color_multiplier);

    return vec4f(color_mix, 1.);
}