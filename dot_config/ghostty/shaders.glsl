// --- CONFIGURATION ---
// To hardcode a trail color: vec4 TRAIL_COLOR = vec4(r, g, b, a);
const float DURATION               = 0.2;  // total animation time in seconds
const float TRAIL_SIZE             = 0.8;  // 0.0 = all corners move together, 0.99 = max smear
const float THRESHOLD_MIN_DISTANCE = 1.5;  // min move distance to show trail (units of cursor height)
const float TRAIL_THICKNESS        = 1.0;  // 1.0 = full cursor height, 0.0 = zero height
const float TRAIL_THICKNESS_X      = 0.9;
const float BLUR                   = 1.0;  // blur px; >= 2.5 forces blur on H/V moves too

// Set to 1 to enable fade gradient along the trail tail
#define FADE_ENABLED 0
const float FADE_EXPONENT = 5.0;

// --- EASING CONSTANTS ---
const float PI               = 3.14159265359;
const float C1_BACK          = 1.70158;
const float C3_BACK          = C1_BACK + 1.0;
const float C4_ELASTIC       = (2.0 * PI) / 3.0;
const float SPRING_STIFFNESS = 9.0;
const float SPRING_DAMPING   = 0.9;

// --- EASING FUNCTIONS (uncomment one) ---

// float ease(float x) { return x; } // Linear
// float ease(float x) { return 1.0 - (1.0 - x) * (1.0 - x); } // EaseOutQuad
// float ease(float x) { return 1.0 - pow(1.0 - x, 3.0); } // EaseOutCubic
// float ease(float x) { return 1.0 - pow(1.0 - x, 4.0); } // EaseOutQuart
// float ease(float x) { return 1.0 - pow(1.0 - x, 5.0); } // EaseOutQuint
// float ease(float x) { return sin((x * PI) / 2.0); } // EaseOutSine
// float ease(float x) { return x == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * x); } // EaseOutExpo

// EaseOutCirc
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

// // EaseOutBack
// float ease(float x) {
//     return 1.0 + C3_BACK * pow(x - 1.0, 3.0) + C1_BACK * pow(x - 1.0, 2.0);
// }

// // EaseOutElastic
// float ease(float x) {
//     return x == 0.0 ? 0.0
//          : x == 1.0 ? 1.0
//          : pow(2.0, -10.0 * x) * sin((x * 10.0 - 0.75) * C4_ELASTIC) + 1.0;
// }

// // Parametric Spring
// float ease(float x) {
//     x = clamp(x, 0.0, 1.0);
//     float decay = exp(-SPRING_DAMPING * SPRING_STIFFNESS * x);
//     float freq  = sqrt(SPRING_STIFFNESS * (1.0 - SPRING_DAMPING * SPRING_DAMPING));
//     float osc   = cos(freq * 6.283185 * x)
//                 + (SPRING_DAMPING * sqrt(SPRING_STIFFNESS) / freq)
//                 * sin(freq * 6.283185 * x);
//     return 1.0 - decay * osc;
// }

// --- SDF HELPERS ---

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Branchless signed-distance segment contribution.
// Based on https://iquilezles.org/articles/distfunctions2d/
// Requires consistent winding order (CW or CCW) - non-convex quads break the sign.
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e    = b - a;
    vec2 w    = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(p - proj, p - proj));

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond  = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    s *= mix(1.0, -1.0, step(0.5, allCond + noneCond));
    return d;
}

float getSdfConvexQuad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);
    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);
    return s * sqrt(d);
}

// Converts pixel coords/sizes to NDC space (divided by height).
// isPosition=1.0 for positions, 0.0 for sizes.
vec2 toNDC(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialias(float dist, float blurAmount) {
    return 1.0 - smoothstep(0.0, toNDC(vec2(blurAmount, blurAmount), 0.0).x, dist);
}

// Maps a corner's dot product with the move direction to an animation duration.
// dot_val in [-2, 2]: > 0.5 = leading, > -0.5 = side, <= -0.5 = trailing.
float getDurationFromDot(float dot_val, float dur_lead, float dur_side, float dur_trail) {
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);
    return mix(mix(dur_trail, dur_side, isSide), dur_lead, isLead);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 TRAIL_COLOR = iCurrentCursorColor;

    fragColor = vec4(0.0);
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu           = toNDC(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);

    vec4 currentCursor  = vec4(toNDC(iCurrentCursor.xy,  1.0), toNDC(iCurrentCursor.zw,  0.0));
    vec4 previousCursor = vec4(toNDC(iPreviousCursor.xy, 1.0), toNDC(iPreviousCursor.zw, 0.0));

    vec2 centerCC   = currentCursor.xy  - (currentCursor.zw  * offsetFactor);
    vec2 halfSizeCC = currentCursor.zw  * 0.5;
    vec2 centerCP   = previousCursor.xy - (previousCursor.zw * offsetFactor);

    float sdfCurrentCursor = getSdfRectangle(vu, centerCC, halfSizeCC);
    float lineLength        = distance(centerCC, centerCP);
    float minDist           = currentCursor.w * THRESHOLD_MIN_DISTANCE;

    vec4  newColor     = fragColor;
    float baseProgress = iTime - iTimeCursorChange;

    if (lineLength > minDist && baseProgress < DURATION - 0.001) {

        // Current cursor corners
        // iCurrentCursor.xy is the -X,+Y corner; .zw is width,height
        float cc_half_h   = currentCursor.w * 0.5;
        float cc_center_y = currentCursor.y - cc_half_h;
        float cc_half_w   = currentCursor.z * 0.5;
        float cc_center_x = currentCursor.x + cc_half_w;

        vec2 cc_tl = vec2(cc_center_x - cc_half_w * TRAIL_THICKNESS_X, cc_center_y + cc_half_h * TRAIL_THICKNESS);
        vec2 cc_tr = vec2(cc_center_x + cc_half_w * TRAIL_THICKNESS_X, cc_center_y + cc_half_h * TRAIL_THICKNESS);
        vec2 cc_bl = vec2(cc_center_x - cc_half_w * TRAIL_THICKNESS_X, cc_center_y - cc_half_h * TRAIL_THICKNESS);
        vec2 cc_br = vec2(cc_center_x + cc_half_w * TRAIL_THICKNESS_X, cc_center_y - cc_half_h * TRAIL_THICKNESS);

        // Previous cursor corners
        float cp_half_h   = previousCursor.w * 0.5;
        float cp_center_y = previousCursor.y - cp_half_h;
        float cp_half_w   = previousCursor.z * 0.5;
        float cp_center_x = previousCursor.x + cp_half_w;

        vec2 cp_tl = vec2(cp_center_x - cp_half_w * TRAIL_THICKNESS_X, cp_center_y + cp_half_h * TRAIL_THICKNESS);
        vec2 cp_tr = vec2(cp_center_x + cp_half_w * TRAIL_THICKNESS_X, cp_center_y + cp_half_h * TRAIL_THICKNESS);
        vec2 cp_bl = vec2(cp_center_x - cp_half_w * TRAIL_THICKNESS_X, cp_center_y - cp_half_h * TRAIL_THICKNESS);
        vec2 cp_br = vec2(cp_center_x + cp_half_w * TRAIL_THICKNESS_X, cp_center_y - cp_half_h * TRAIL_THICKNESS);

        // Per-corner animation durations based on alignment with move direction.
        // TRAIL_SIZE clamped to 0.99: at 1.0, dur_lead = 0 -> divide-by-zero below.
        float safeTrailSize = clamp(TRAIL_SIZE, 0.0, 0.99);
        float dur_trail = DURATION;
        float dur_lead  = DURATION * (1.0 - safeTrailSize);
        float dur_side  = (dur_lead + dur_trail) * 0.5;

        vec2 moveVec = centerCC - centerCP;
        vec2 s       = sign(moveVec);

        float dot_tl = dot(vec2(-1.0,  1.0), s);
        float dot_tr = dot(vec2( 1.0,  1.0), s);
        float dot_bl = dot(vec2(-1.0, -1.0), s);
        float dot_br = dot(vec2( 1.0, -1.0), s);

        float dur_tl = getDurationFromDot(dot_tl, dur_lead, dur_side, dur_trail);
        float dur_tr = getDurationFromDot(dot_tr, dur_lead, dur_side, dur_trail);
        float dur_bl = getDurationFromDot(dot_bl, dur_lead, dur_side, dur_trail);
        float dur_br = getDurationFromDot(dot_br, dur_lead, dur_side, dur_trail);

        // Unify left/right rail corners on pure H/V movement
        float isMovingRight  = step(0.5,  s.x);
        float isMovingLeft   = step(0.5, -s.x);
        float dur_right_rail = getDurationFromDot((dot_tr + dot_br) * 0.5, dur_lead, dur_side, dur_trail);
        float dur_left_rail  = getDurationFromDot((dot_tl + dot_bl) * 0.5, dur_lead, dur_side, dur_trail);

        float final_dur_tl = mix(dur_tl, dur_left_rail,  isMovingLeft);
        float final_dur_bl = mix(dur_bl, dur_left_rail,  isMovingLeft);
        float final_dur_tr = mix(dur_tr, dur_right_rail, isMovingRight);
        float final_dur_br = mix(dur_br, dur_right_rail, isMovingRight);

        // Interpolate corners
        vec2 v_tl = mix(cp_tl, cc_tl, ease(clamp(baseProgress / final_dur_tl, 0.0, 1.0)));
        vec2 v_tr = mix(cp_tr, cc_tr, ease(clamp(baseProgress / final_dur_tr, 0.0, 1.0)));
        vec2 v_br = mix(cp_br, cc_br, ease(clamp(baseProgress / final_dur_br, 0.0, 1.0)));
        vec2 v_bl = mix(cp_bl, cc_bl, ease(clamp(baseProgress / final_dur_bl, 0.0, 1.0)));

        // Draw trail quad (winding: tl -> tr -> br -> bl)
        float sdfTrail = getSdfConvexQuad(vu, v_tl, v_tr, v_br, v_bl);

        // Suppress blur on H/V moves to avoid pulse artifact; BLUR >= 2.5 always blurs
        float effectiveBlur = BLUR;
        if (BLUR < 2.5) {
            effectiveBlur = mix(0.0, BLUR, abs(s.x) * abs(s.y));
        }

        float shapeAlpha = antialias(sdfTrail, effectiveBlur);

        #if FADE_ENABLED
        vec2  fragVec      = vu - centerCP;
        float fadeProgress = clamp(dot(fragVec, moveVec) / (dot(moveVec, moveVec) + 1e-6), 0.0, 1.0);
        TRAIL_COLOR.a *= pow(fadeProgress, FADE_EXPONENT);
        #endif

        newColor = mix(newColor, vec4(TRAIL_COLOR.rgb, newColor.a), TRAIL_COLOR.a * shapeAlpha);
        newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.0));
    }

    fragColor = newColor;
}
