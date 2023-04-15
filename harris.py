import cv2
import numpy as np

threshold = 10

#image stuff
image = cv2.imread('square.png')
  
# convert the input image into
# grayscale color space
input_img = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
cv2.imshow('Input Image', input_img)
cv2.waitKey(0)

output_img = input_img.copy()
final_img = np.zeros(input_img.shape)

#shifts
shifts = ((1, 0), (-1, 0), (0, 1), (0, -1))

#begin process
for i in range(60):
    
    #find corners with harris
    blurred = cv2.GaussianBlur(input_img,(5,5),cv2.BORDER_DEFAULT)
    operatedImage = np.float32(blurred)
    dest = cv2.cornerHarris(operatedImage, 2, 5, 0.07)
    dest = cv2.dilate(dest, None)
    image[dest < 0.01 * dest.max()] = [255,255,255]
    image[dest > 0.01 * dest.max()] = [0,0,255]

    for x in range(1, input_img.shape[0]-1):
        for y in range(1, input_img.shape[1]-1):
            
            if (input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1]):
                continue

            if (input_img[x, y] > 0 and input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1] == 0):
                continue
            
            #detect edges
            smallest = 255
            largest = 0

            for i in range(4):
                if (input_img[x+shifts[i][0], y+shifts[i][1]] > largest):
                    largest = input_img[x+shifts[i][0], y+shifts[i][1]]
                elif (input_img[x+shifts[i][0], y+shifts[i][1]] < smallest):
                    smallest = input_img[x+shifts[i][0], y+shifts[i][1]]

            if (largest-smallest > threshold):
                output_img[x,y] = 255

    harris_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    for x in range(1, final_img.shape[0]-1):
        for y in range(1, final_img.shape[1]-1):
            if (harris_gray[x,y] < 255):
                final_img[x,y] = 76
    
    #restore harris starting point
    image = cv2.cvtColor(output_img.copy(), cv2.COLOR_GRAY2BGR)
    input_img = output_img.copy()

#do a final AND to get the inner skeleton
for x in range(1, final_img.shape[0]-1):
    for y in range(1, final_img.shape[1]-1):
        if (harris_gray[x,y] < 255 or output_img[x,y] < 255):
            final_img[x,y] = 76

cv2.imshow('Skeleton', final_img)
cv2.waitKey(0)