function img = threshold_im(img, th)
    img(find(img < th)) = 0;
    img(find(img)) = 255;
end