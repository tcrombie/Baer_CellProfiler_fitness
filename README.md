# Baer_CellProfiler_fitness
Optimization of a CellProfiler pipeline for measuring competitive fitness following Crombie et al. 2018

## README

1. I used example images from `/Users/tim/Dropbox/AndersenLab/LabFolders/Tim/projects/Baer/temp_share/Plate6`
2. I made a well mask to account for the drift in the stage across a row. The stage on David’s scope tends jitter well positions in the images. I think the well alignment gets progressively worse when moving across a row. The mask is designed to be conservative and mask the edges of the well no matter where they occur in the image. To make the mask I built a binary image in photoshop by circling well A01, A12, G01 and G10 of a microplate. These wells are slightly shifted from one another so that the intersection of the well boundaries form an ellipse. I then shrunk this shape to 97.5% of its original size to provide a buffer around the well edge. This binary image is loaded with the well images and is applied as a mask saving computational time for each image processed and I think it performs better too.
    1. opened all 4 images in photoshop
    2. made a circle to outline well for G10 perfectly.
    3. Copied that circle to other 3 images to see alignment. - It did not align with other images
    4. Shrunk the circle by 5% and shaped it until the new ellipse fit within the desired well region of all images.
    5. Saved white cirlce with black background as a greyscale png `20220411_mask_v3.png` this is can be used by CellProfiler as a binary image for masking.
3.  Opened the example pipeline from the 2018 paper. Replaced the cropping and background correction modules with updated versions.
    1. I downloaded the supplemental file from Crombie et al. 2018 [https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6195253/bin/pone.0201507.s005.zip](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6195253/bin/pone.0201507.s005.zip)
    2. I opened the Andersen Lab CellProfiler pipeline we developed to process our GWA studies. [https://github.com/AndersenLab/CellProfiler/tree/master/pipelines](https://github.com/AndersenLab/CellProfiler/tree/master/pipelines)
4. **Pipeline 1:** Identifying single worms for the worm model - `/Users/tim/repos/Baer_CellProfiler_fitness/CellProfiler/pipelines/20220411_identify_single_worms.cpproj`
    1. I added 6_A01_PS11_1_BF.tif, 6_A10_PS20_1_BF.tif, 6_G01_PS11_7_BF.tif, 6_G10_PS20_7_BF.tif, and 20220411_mask_v3.png to images module in CP 4.2.1
    2. I used Andersen Lab GWA pipeline as a model to mask the well using `/Users/tim/repos/Baer_CellProfiler_fitness/CellProfiler/mask/20220411_mask_v3.png` and to correct the illumination. The illumination correction is MUCH better than Crombie et al. 2018.
        
        ![Screen Shot 2022-04-11 at 1.25.00 PM.png](Baer_CellP%2039f52/Screen_Shot_2022-04-11_at_1.25.00_PM.png)
        
    3. The pipeline finish without fail.
    4. In the untangling step I think we can size select primary objects to focus on non-overlapping L1 - L2 stage animals and avoid debris, adults, and large worm clusters.  
5. **Pipeline 2:** Making a worm model
    1. Used the single worm images from pipeline 1 and processed them with `/Users/tim/repos/Baer_CellProfiler_fitness/CellProfiler/pipelines/20220411_create_worm_model.cpproj` 
    2. Ran without an issue.
6. **Pipeline 3**: Untangling worms and outputting data
    1. The Regular expression that works with our naming is: `^(?P<Plate>.*)(?P<Well>[A-P][0-9]{1,2})(?P<Strain>.*)*(?P<Rep>.*)*(?P<image_type>[A-P][A-P]).tif` 
    2. I am using the Andersen Lab thresholding and well masking approach added to the Crombie et al. 2018 GFP detection approach
    3. I changed the acceptable diameter of worm objects to 10 - 30 to try and select only L1-L2 worms.
    4. I reworked the thresholding strategy used in the IdentifyPrimaryObjects module for GFPobjects. The old method used a manual approach, which might be problematic for a complete image set. The new method is: Minimum Cross-Entropy
        1. This is difficult - I was using the WormmaskedGFP as an input but I think we should use the maskGFP image instead. Also BF worm objects and GFP objects are not aligned with BF objects see major issue below.
            
            ![Screen Shot 2022-04-11 at 5.12.44 PM.png](Baer_CellP%2039f52/Screen_Shot_2022-04-11_at_5.12.44_PM.png)
            
        2. The GFP object identification looks good above. See settings below
            
            ![Screen Shot 2022-04-11 at 5.13.26 PM.png](Baer_CellP%2039f52/Screen_Shot_2022-04-11_at_5.13.26_PM.png)
            
    5. **MAJOR ISSUE:** The BF and GFP images were not taken successively within a well. This means that many BF worm objects do not align with the GFP objects for the same worm.
    

## General Notes

- CellProfiler 4.2.1 is much more stable than previous versions, e.g., 4.0.3 - 4.0.7
- **MAJOR ISSUE:** The BF and GFP images were not taken successively within a well. This means that many BF worm objects do not align with the GFP objects for the same worm.
