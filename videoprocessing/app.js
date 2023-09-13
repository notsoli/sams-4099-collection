import { default as seagulls } from './seagulls.js'
import { default as Video } from './helpers/video.js'

const sg = await seagulls.init(),
    frag = await seagulls.import( './frag.wgsl' ),
    shader = seagulls.constants.vertex + frag

await Video.init()

let click_pos = [0, 0]
window.onclick = (e) => {
    time_since_click = 0
    sg.uniforms.click_pos = [e.clientX, e.clientY]
}
let time_since_click = 0

const resolution = [ window.innerWidth, window.innerHeight ]
let frame = 0

let threshold = 0.5
let noise_scale = 50;
window.onkeydown = (e) => {
    if (e.keyCode == 37 && threshold > 0) {
        threshold -= 0.05
        sg.uniforms.threshold = threshold
    } else if (e.keyCode == 39 && threshold < 1) {
        threshold += 0.05
        sg.uniforms.threshold = threshold
    } else if (e.keyCode == 38) {
        noise_scale += 5;
        sg.uniforms.noise_scale = noise_scale;
    } else if (e.keyCode == 40) {
        noise_scale -= 5;
        sg.uniforms.noise_scale = noise_scale;
    }
}

sg
    .uniforms({ frame, resolution, click_pos, time_since_click, threshold, noise_scale})
    .onframe( () => {
        sg.uniforms.frame = frame++
        sg.uniforms.time_since_click = time_since_click++
    })
    .textures([ Video.element ])
    .render( shader )
    .run()