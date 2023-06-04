clc;
close all;
RGB2 = imread('kivi1.jpg');
cform = makecform('srgb2lab');
lab_he = applycform(RGB2,cform);
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors=3;
[cluster_idx cluster_center]=kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
%imshow(pixel_labels,[]);
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
for k = 1:nColors
 color = RGB2;
 color(rgb_label ~= k) = 0;
 segmented_images{k} = color;
end
%imshow(segmented_images{2}), title('2. kümedeki nesneler');
%%
hy=fspecial('sobel');
hx=hy;
Iy=imfilter(double(segmented_images{2}),hy,'replicate');
Ix=imfilter(double(segmented_images{2}),hx,'replicate');
gradmag=sqrt(Ix.^6+Iy.^6);
%imshow(gradmag);
se=strel('ball',17,6);
Io=imopen(segmented_images{2},se);
%imshow(Io);
%%
r = Io(:, :, 1);
g = Io(:, :, 2);
b = Io(:, :, 3);
justGreen = g;
bw = justGreen > 50;
imagesc(bw);
colormap(gray);
ball1 = bwareaopen(bw, 30);
imagesc(ball1);
%%
D = -bwdist(~bw); 
%figure, imshow(D,[]), title('Distancetransform of ~bw')
Ld = watershed(D);
bw2 = bw;
bw2(Ld == 0) = 0;
%imshow(bw2)
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;
bw3 = imfill(bw3,'hole');
%imshow(bw3)
%%
[L,num] = bwlabel(bw2);  
stats = regionprops(bw2, 'Area');
count = 0;
    for n=1:num
        a = stats(n).Area;  
        switch logical(true)
            case a> 40000
                count = count + 3;
            case a >25000 &&  a <30000
                count = count + 2;
            case a >20000 &&  a <25000
                count = count + 2;
            case a >15000 &&  a <20000
                count = count + 1;
            case a >10000 &&  a <15000
                count = count + 1;
            case a >1000 &&  a <10000
                count = count + 1;
            otherwise
                count = count + 0;
        end
    end
    
set(gcf,'WindowState','maximized')
subplot(1,5,1), imshow(RGB2),title('Orijinal resim')
subplot(1,5,2), imshow(lab_he),title('Renk alanları dönüştürülmüş resim')
subplot(1,5,3), imshow(segmented_images{2}),title('Kahverengi tonları ayrılmış resim')
subplot(1,5,4), imshow(Io),title('Yuvarlak şekillerin belirlenmesi') 
subplot(1,5,5), imshow(bw2),title(['Griye dönüşüm sonrası, kivi sayısı = ',num2str(count),' Adet'])
