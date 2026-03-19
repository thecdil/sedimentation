Animation & Interactive Elements Overview
Interactive Elements Inventory
1. Tributary Button Particle System (tributary-buttons.js)
Animation Type: Canvas-based particle disintegration with page transition overlay
Duration: 700ms (fast) or 1400ms (normal)
Trigger: Click on tributary navigation buttons
Current Implementation:
Particles extracted from button images dissolve in directional flow
Uses requestAnimationFrame for particle animation
Includes turbulence, gravity, and opacity fade effects
Full-screen overlay fades in during transition (0.3s ease)
2. Scrollama Text Animations (essay-scroll-js.html)
Animation Type: Scroll-triggered fade-in/fade-out with background color transitions
Duration: 750ms for fade effects (defined in CSS)
Trigger: Scroll position (24% offset)
Current Implementation:
Steps fade in/out as user scrolls
Background colors change per step
No explicit easing defined in transitions
3. Button Hover/Active States (cb.css)
Tributary Buttons:
Hover: translateY(-3px) with box-shadow, no duration specified
Active: translateY(-1px) with reduced shadow
Uses cubic-bezier(0.4, 0, 0.2, 1) (ease-out equivalent)
Duration: 300ms
Icon scale on hover: scale(1.08) at 300ms
4. Continue Button Smooth Scroll (tributary-buttons.js:329-379)
Animation: behavior: 'smooth' native scroll
No explicit duration control (browser-dependent)
5. River SVG Animations (river-svg.html)
Type: SVG stroke-dasharray animation for flowing effect
Duration: 5s for main river, 4s for tributaries
Gradient pulsing: 3s infinite animation
Particles (optional): Canvas-based particle system with continuous flow
6. Navigation Menu Animations (cb.css)
Full-page nav overlay: Opacity transition 400ms ease
River segment hover: 500ms cubic-bezier + glow effects
Various shimmer/pulse keyframe animations: 3s, 1.5s, 2s durations
Suggestions Based on Animation Skill Directives
Element	Current State	Issue	Recommended Change	Why
Tributary button hover	transition: all .3s cubic-bezier(0.4, 0, 0.2, 1)	Uses all instead of specific properties	transition: transform 300ms cubic-bezier(0.23, 1, 0.32, 1), box-shadow 300ms cubic-bezier(0.23, 1, 0.32, 1)	Specify exact properties; use stronger ease-out curve
Button active state	transform: translateY(-1px) with same timing	No differentiated timing/easing	Keep 300ms but ensure instant feedback feels responsive	Active states should feel immediate
Scrollama fade transitions	.step { transition: opacity .75s ease-in } and .step { transition: opacity .75s ease-out }	Uses ease-in for entry	Change to transition: opacity 600ms cubic-bezier(0.23, 1, 0.32, 1) for fade-in	Never use ease-in for UI; use strong ease-out
Particle transition overlay	transition: opacity 0.3s ease	Duration possibly too short for seamless feel	Consider 400-500ms with cubic-bezier(0.23, 1, 0.32, 1)	Gives more elegant transition between pages
Continue button scroll	Uses native behavior: 'smooth'	No control over duration/easing	Implement custom scroll animation with 400-600ms and ease-out curve	More control over perceived responsiveness
River segment hover	transition: all .5s cubic-bezier(0.4, 0, 0.2, 1)	Uses all; 500ms may be too slow	transition: filter 200ms ease-out, transform 200ms ease-out	Faster hover = more responsive feel
Choice button images	transition: all .3s ease	Generic ease and all	transition: transform 300ms cubic-bezier(0.23, 1, 0.32, 1), filter 300ms ease	Stronger curve, specific properties
Nav overlay opening	transition: opacity .4s ease, visibility .4s ease	Good duration, weak easing	transition: opacity 400ms cubic-bezier(0.23, 1, 0.32, 1), visibility 400ms cubic-bezier(0.23, 1, 0.32, 1)	Stronger curve for more intentional feel
Essay Reading Experience (_tributaries files)
The tributary essay files use:
Scrollama for progressive disclosure - Good pattern for long-form content
Fade-in animations on scroll - Creates gentle rhythm
Image galleries with Spotlight modal viewer
Tributary button junctions - Natural narrative branching points
Specific concerns for essay reading:
Fade transition timing (750ms) - This is on the slower side. Consider 500-600ms for better reading flow
Ease-in usage - The fade-in uses ease-in which feels sluggish. Should be ease-out
No reduced-motion support visible - Essays should respect prefers-reduced-motion
Background color transitions - No explicit duration, may be jarring. Should be 400-600ms ease
Image gallery modals - Uses Spotlight library (external), ensure its animations align with site philosophy
Positive Highlights
✓ Particle system uses requestAnimationFrame (correct for JS animations)
✓ Transform and opacity used for animations (GPU-accelerated)
✓ Scroll-based animations use IntersectionObserver pattern via Scrollama
✓ Tributary button concept creates engaging narrative branching
✓ Uses cubic-bezier curves (though could be stronger)
Priority Recommendations
High Priority:
Replace all ease-in with ease-out or stronger custom curves
Change all transition: all to specify exact properties
Add @media (prefers-reduced-motion: reduce) support throughout
Strengthen cubic-bezier curves to (0.23, 1, 0.32, 1) for more punch
Medium Priority: 5. Reduce scrollama fade duration from 750ms to 500-600ms 6. Add explicit duration to background color transitions 7. Speed up river segment hover from 500ms to 200-250ms 8. Consider adding :active scale states where missing Low Priority: 9. Implement custom smooth scroll with controlled duration 10. Review Spotlight modal animations for consistency 11. Add subtle :active states to more interactive elements
Overall Assessment
The site has thoughtful interactive elements that support the narrative metaphor of rivers and tributaries. The particle disintegration effect is creative and thematically appropriate. However, many animations use generic easing (ease, ease-in) and transition: all, which reduces their impact and performance. The essay reading experience would benefit from tighter animation timing and more intentional easing curves to create the "compound of invisible details" that makes interfaces feel right.