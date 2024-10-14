# TestingSuitePropixxRig

This code-base contain a small set of timing tests for a Vpixx Propixx rig.  The Propixx projector runs at 120 Hz and these are the types of stimuli that bonnen lab currently uses (cerca 2024). These tests are set up to check that reinstallations or updates have not changed the rate of frame drops.

There are currently 4 tests:

1. TestingPpxMultisampling.m -- This checks for frame drops as you increase full screen multisampling parameters.
2. TestingPpxMultisamplingPolygonTarget.m -- This checks for frame drops as you increase full screen multisampling parameters with a more complex multi-polygone stimulus.
3. TestingTpx.m --- This checks for frame drops and the time required for Trackpixx
