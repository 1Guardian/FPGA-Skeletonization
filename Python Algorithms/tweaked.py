import cv2

threshold = 100

#image stuff
input_img = cv2.imread("square.png", 0)
cv2.imshow('Input Image', input_img)
cv2.waitKey(0)

#shifts
shifts = ((1, 0), (-1, 0), (0, 1), (0, -1))

output_img = input_img.copy()

#begin process
for i in range(1):
    for x in range(1, input_img.shape[0]-1):
        for y in range(1, input_img.shape[1]-1):
            
            if (input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1]):
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

                #check if corner
                if (((input_img[x-1, y-1] > threshold) or (input_img[x+1, y+1] > threshold)) and
                    ((input_img[x+1, y-1] > threshold) or (input_img[x-1, y+1] > threshold)) and
                    ((input_img[x, y-1] > threshold) or (input_img[x, y+1] > threshold)) and
                    ((input_img[x+1, y] > threshold) or (input_img[x-1, y] > threshold))):
                        output_img[x,y] = 0

                else:
                    output_img[x,y] = 100

    input_img = output_img.copy()

cv2.imshow('Detected Corners', output_img)
cv2.waitKey(0)