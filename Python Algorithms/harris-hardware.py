import cv2
import numpy as np
import sys

#proposal:
#take in image, run harris on image
#thin image, put harris detections in 
#output image, and reset with the new
#image harris is processing being the
#new image produced by thinning.
#when done:
#OR the thinned image and output image

threshold = 10

#image stuff
image = cv2.imread('human.png')
  
# convert the input image into
# grayscale color space
input_img = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
cv2.imshow('Input Image', input_img)
cv2.waitKey(0)

output_img = input_img.copy()
final_img = np.zeros(input_img.shape)

#shifts
shifts = ((1, 0), (-1, 0), (0, 1), (0, -1))

#Sobel operator kernels.
sobel_x = np.array([[-1, 0, 1],[-2, 0, 2],[-1, 0, 1]])
sobel_y = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]])

#begin process
for i in range(1):

    #for each pixel in image
    for x in range(1, input_img.shape[0]-1):
        for y in range(1, input_img.shape[1]-1):
            
            #skip pixel if it is interior or background
            if (input_img[x, y] == input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1]):
                continue
            
            #run harris
            #============================================================================================================

            #check the 5 neighborhood to get the harris rating (flattened)
            c_n = (np.array(input_img[x-2: x+3, y-2:y+3])).flatten()
            Ix = []
            Iy = []
            Ixy = []
             
            #Ix partial derivatives
            #============================================================================================================
            #position x-1 y-1
            Ix.append(((c_n[0] * -1) + (c_n[2] * 1) + (c_n[5] * -2) + (c_n[7] * 2) + (c_n[10] * -1) + (c_n[12] * 1)) ** 2)

            #position x y-1
            Ix.append(((c_n[1] * -1) + (c_n[3] * 1) + (c_n[6] * -2) + (c_n[8] * 2) + (c_n[11] * -1) + (c_n[13] * 1)) ** 2)

            #position x+1 y-1
            Ix.append(((c_n[2] * -1) + (c_n[4] * 1) + (c_n[7] * -2) + (c_n[9] * 2) + (c_n[12] * -1) + (c_n[14] * 1)) ** 2)

            #position x-1 y
            Ix.append(((c_n[5] * -1) + (c_n[7] * 1) + (c_n[10] * -2) + (c_n[12] * 2) + (c_n[15] * -1) + (c_n[17] * 1)) ** 2)

            #position x y
            Ix.append(((c_n[6] * -1) + (c_n[8] * 1) + (c_n[11] * -2) + (c_n[13] * 2) + (c_n[16] * -1) + (c_n[18] * 1)) ** 2)

            #position x+1 y
            Ix.append(((c_n[7] * -1) + (c_n[9] * 1) + (c_n[12] * -2) + (c_n[14] * 2) + (c_n[17] * -1) + (c_n[19] * 1)) ** 2)

            #position x-1 y+1
            Ix.append(((c_n[10] * -1) + (c_n[12] * 1) + (c_n[15] * -2) + (c_n[17] * 2) + (c_n[20] * -1) + (c_n[22] * 1)) ** 2)

            #position x y+1
            Ix.append(((c_n[11] * -1) + (c_n[13] * 1) + (c_n[16] * -2) + (c_n[18] * 2) + (c_n[21] * -1) + (c_n[23] * 1)) ** 2)

            #position x+1 y+1
            Ix.append(((c_n[12] * -1) + (c_n[14] * 1) + (c_n[17] * -2) + (c_n[19] * 2) + (c_n[22] * -1) + (c_n[24] * 1)) ** 2)

        
            #Iy partial derivatives
            #============================================================================================================
            #position x-1 y-1
            Iy.append(((c_n[0] * -1) + (c_n[1] * -2) + (c_n[2] * -1) + (c_n[10] * 1) + (c_n[11] * 2) + (c_n[12] * 1)) ** 2)

            #position x y-1
            Iy.append(((c_n[1] * -1) + (c_n[2] * -2) + (c_n[3] * -1) + (c_n[11] * 1) + (c_n[12] * 2) + (c_n[13] * 1)) ** 2)

            #position x+1 y-1
            Iy.append(((c_n[2] * -1) + (c_n[3] * -2) + (c_n[4] * -1) + (c_n[12] * 1) + (c_n[13] * 2) + (c_n[14] * 1)) ** 2)

            #position x-1 y
            Iy.append(((c_n[5] * -1) + (c_n[6] * -2) + (c_n[7] * -1) + (c_n[15] * 1) + (c_n[16] * 2) + (c_n[17] * 1)) ** 2)

            #position x y
            Iy.append(((c_n[6] * -1) + (c_n[7] * -2) + (c_n[8] * -1) + (c_n[16] * 1) + (c_n[17] * 2) + (c_n[18] * 1)) ** 2)

            #position x+1 y
            Iy.append(((c_n[7] * -1) + (c_n[8] * -2) + (c_n[9] * -1) + (c_n[17] * 1) + (c_n[18] * 2) + (c_n[19] * 1)) ** 2)

            #position x-1 y+1
            Iy.append(((c_n[10] * -1) + (c_n[11] * -2) + (c_n[12] * -1) + (c_n[20] * 1) + (c_n[21] * 2) + (c_n[22] * 1)) ** 2)

            #position x y+1
            Iy.append(((c_n[11] * -1) + (c_n[12] * -2) + (c_n[13] * -1) + (c_n[21] * 1) + (c_n[22] * 2) + (c_n[23] * 1)) ** 2)

            #position x+1 y+1
            Iy.append(((c_n[12] * -1) + (c_n[13] * -2) + (c_n[14] * -1) + (c_n[22] * 1) + (c_n[23] * 2) + (c_n[24] * 1)) ** 2)

            #Ixy partial derivatives
            for i in range(9):
                Ixy.append(Ix[i] * Iy[i])

            #now calc Sxx Sxy Syy
            Sxx = np.array(Ix).sum()
            Sxy = np.array(Ixy).sum()
            Syy = np.array(Iy).sum()

            #calc the det and trace
            det = (Sxx * Syy) - (Sxy**2)
            trace = Sxx + Syy

            #calc r 
            r = det - 0.07*(trace**2)

            if (r > threshold):
                final_img[x,y] = 255

            else:

                #run thinning algorithm
                smallest = 255
                largest = 0

                for i in range(4):
                    if (input_img[x+shifts[i][0], y+shifts[i][1]] > largest):
                        largest = input_img[x+shifts[i][0], y+shifts[i][1]]
                    elif (input_img[x+shifts[i][0], y+shifts[i][1]] < smallest):
                        smallest = input_img[x+shifts[i][0], y+shifts[i][1]]

                if (largest-smallest > threshold):
                    output_img[x,y] = 255


cv2.imshow('Skeleton', final_img)
cv2.waitKey(0)

#do a final AND to get the inner skeleton
for x in range(1, final_img.shape[0]-1):
    for y in range(1, final_img.shape[1]-1):
        if (harris_gray[x,y] < 255 or output_img[x,y] < 255):
            final_img[x,y] = 76

cv2.imshow('Skeleton', final_img)
cv2.waitKey(0)