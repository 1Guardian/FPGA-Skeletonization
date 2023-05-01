import cv2
import numpy as np

square = np.zeros((8,8))
squareInner = np.ones((4,4))
square[2:6, 2:6] = squareInner

image = square
cv2.imshow("original", square)
cv2.waitKey(0)

thresh = 0.8

harrisMatrix = np.copy(np.float64(image))
Ix = np.copy(np.float32(image))
Iy = np.copy(np.float32(image))

#use algorithm descibed in paper
for x in range(8):
    for y in range(8):
        if (x > 1 and y > 1 and x < 6 and y < 6):

            #pretend like we got this legit
            #get in 25 cycles
            neighbors = np.copy(image[x-2: x+3, y-2: y+3]).flatten()

            #simple static 9 val array to store values
            Ix = np.copy(image[x-1:x+2, y-1: y+2])
            Iy = np.copy(image[x-1:x+2, y-1: y+2])

            #find Ix and Iy
            #1 cycle
            Ix[0][0] = (neighbors[0] * -1) + (neighbors[1] * 0) + (neighbors[2] * 1) + (neighbors[5] * -2) + (neighbors[6] * 0) + (neighbors[7] * 2) + (neighbors[10] * -1) + (neighbors[11] * 0) + (neighbors[12] * 1)
            Ix[0][1] = (neighbors[1] * -1) + (neighbors[2] * 0) + (neighbors[3] * 1) + (neighbors[6] * -2) + (neighbors[7] * 0) + (neighbors[8] * 2) + (neighbors[11] * -1) + (neighbors[12] * 0) + (neighbors[13] * 1)
            Ix[0][2] = (neighbors[2] * -1) + (neighbors[3] * 0) + (neighbors[4] * 1) + (neighbors[7] * -2) + (neighbors[8] * 0) + (neighbors[9] * 2) + (neighbors[12] * -1) + (neighbors[13] * 0) + (neighbors[14] * 1)
            
            Ix[1][0] = (neighbors[5] * -1) + (neighbors[6] * 0) + (neighbors[7] * 1) + (neighbors[10] * -2) + (neighbors[11] * 0) + (neighbors[12] * 2) + (neighbors[15] * -1) + (neighbors[16] * 0) + (neighbors[17] * 1)
            Ix[1][1] = (neighbors[6] * -1) + (neighbors[7] * 0) + (neighbors[8] * 1) + (neighbors[11] * -2) + (neighbors[12] * 0) + (neighbors[13] * 2) + (neighbors[16] * -1) + (neighbors[17] * 0) + (neighbors[18] * 1)
            Ix[1][2] = (neighbors[7] * -1) + (neighbors[8] * 0) + (neighbors[9] * 1) + (neighbors[12] * -2) + (neighbors[13] * 0) + (neighbors[14] * 2) + (neighbors[17] * -1) + (neighbors[18] * 0) + (neighbors[19] * 1)

            Ix[2][0] = (neighbors[10] * -1) + (neighbors[11] * 0) + (neighbors[12] * 1) + (neighbors[15] * -2) + (neighbors[16] * 0) + (neighbors[17] * 2) + (neighbors[20] * -1) + (neighbors[21] * 0) + (neighbors[22] * 1)
            Ix[2][1] = (neighbors[11] * -1) + (neighbors[12] * 0) + (neighbors[13] * 1) + (neighbors[16] * -2) + (neighbors[17] * 0) + (neighbors[18] * 2) + (neighbors[21] * -1) + (neighbors[22] * 0) + (neighbors[23] * 1)
            Ix[2][2] = (neighbors[12] * -1) + (neighbors[13] * 0) + (neighbors[14] * 1) + (neighbors[17] * -2) + (neighbors[18] * 0) + (neighbors[19] * 2) + (neighbors[22] * -1) + (neighbors[23] * 0) + (neighbors[24] * 1)

            #Iy
            Iy[0][0] = (neighbors[0] * -1) + (neighbors[1] * -2) + (neighbors[2] * -1) + (neighbors[5] * 0) + (neighbors[6] * 0) + (neighbors[7] * 0) + (neighbors[10] * 1) + (neighbors[11] * 2) + (neighbors[12] * 1)
            Iy[0][1] = (neighbors[1] * -1) + (neighbors[2] * -2) + (neighbors[3] * -1) + (neighbors[6] * 0) + (neighbors[7] * 0) + (neighbors[8] * 0) + (neighbors[11] * 1) + (neighbors[12] * 2) + (neighbors[13] * 1)
            Iy[0][2] = (neighbors[2] * -1) + (neighbors[3] * -2) + (neighbors[4] * -1) + (neighbors[7] * 0) + (neighbors[8] * 0) + (neighbors[9] * 0) + (neighbors[12] * 1) + (neighbors[13] * 2) + (neighbors[14] * 1)
            
            Iy[1][0] = (neighbors[5] * -1) + (neighbors[6] * -2) + (neighbors[7] * -1) + (neighbors[10] * 0) + (neighbors[11] * 0) + (neighbors[12] * 0) + (neighbors[15] * 1) + (neighbors[16] * 2) + (neighbors[17] * 1)
            Iy[1][1] = (neighbors[6] * -1) + (neighbors[7] * -2) + (neighbors[8] * -1) + (neighbors[11] * 0) + (neighbors[12] * 0) + (neighbors[13] * 0) + (neighbors[16] * 1) + (neighbors[17] * 2) + (neighbors[18] * 1)
            Iy[1][2] = (neighbors[7] * -1) + (neighbors[8] * -2) + (neighbors[9] * -1) + (neighbors[12] * 0) + (neighbors[13] * 0) + (neighbors[14] * 0) + (neighbors[17] * 1) + (neighbors[18] * 2) + (neighbors[19] * 1)

            Iy[2][0] = (neighbors[10] * -1) + (neighbors[11] * -2) + (neighbors[12] * -1) + (neighbors[15] * 0) + (neighbors[16] * 0) + (neighbors[17] * 0) + (neighbors[20] * 1) + (neighbors[21] * 2) + (neighbors[22] * 1)
            Iy[2][1] = (neighbors[11] * -1) + (neighbors[12] * -2) + (neighbors[13] * -1) + (neighbors[16] * 0) + (neighbors[17] * 0) + (neighbors[18] * 0) + (neighbors[21] * 1) + (neighbors[22] * 2) + (neighbors[23] * 1)
            Iy[2][2] = (neighbors[12] * -1) + (neighbors[13] * -2) + (neighbors[14] * -1) + (neighbors[17] * 0) + (neighbors[18] * 0) + (neighbors[19] * 0) + (neighbors[22] * 1) + (neighbors[23] * 2) + (neighbors[24] * 1)

            #will take 1 cycle too 
            #find the squares
            Ixx = np.zeros((3,3))
            Iyy = np.zeros((3,3))
            Ixy = np.zeros((3,3))

            Ixx[0][0] = Ix[0][0] * Ix[0][0]
            Ixx[0][1] = Ix[0][1] * Ix[0][1]
            Ixx[0][2] = Ix[0][2] * Ix[0][2]
            Ixx[1][0] = Ix[1][0] * Ix[1][0]
            Ixx[1][1] = Ix[1][1] * Ix[1][1]
            Ixx[1][2] = Ix[1][2] * Ix[1][2]
            Ixx[2][0] = Ix[2][0] * Ix[2][0]
            Ixx[2][1] = Ix[2][1] * Ix[2][1]
            Ixx[2][2] = Ix[2][2] * Ix[2][2]

            Iyy[0][0] = Iy[0][0] * Iy[0][0]
            Iyy[0][1] = Iy[0][1] * Iy[0][1]
            Iyy[0][2] = Iy[0][2] * Iy[0][2]
            Iyy[1][0] = Iy[1][0] * Iy[1][0]
            Iyy[1][1] = Iy[1][1] * Iy[1][1]
            Iyy[1][2] = Iy[1][2] * Iy[1][2]
            Iyy[2][0] = Iy[2][0] * Iy[2][0]
            Iyy[2][1] = Iy[2][1] * Iy[2][1]
            Iyy[2][2] = Iy[2][2] * Iy[2][2]

            Ixy[0][0] = Ix[0][0] * Iy[0][0]
            Ixy[0][1] = Ix[0][1] * Iy[0][1]
            Ixy[0][2] = Ix[0][2] * Iy[0][2]
            Ixy[1][0] = Ix[1][0] * Iy[1][0]
            Ixy[1][1] = Ix[1][1] * Iy[1][1]
            Ixy[1][2] = Ix[1][2] * Iy[1][2]
            Ixy[2][0] = Ix[2][0] * Iy[2][0]
            Ixy[2][1] = Ix[2][1] * Iy[2][1]
            Ixy[2][2] = Ix[2][2] * Iy[2][2]

            #guassian
            #one more cycle
            Ixx = cv2.GaussianBlur(Ixx,(3,3),cv2.BORDER_DEFAULT)
            Iyy = cv2.GaussianBlur(Iyy,(3,3),cv2.BORDER_DEFAULT)
            Ixy = cv2.GaussianBlur(Ixy,(3,3),cv2.BORDER_DEFAULT)

            #store value in BRAM until end, then dump values in N*N cycles to DRAM (superCycle)
            harrisMatrix[x][y] = ((Ixx[1][1] * Iyy[1][1]) - (Ixy[1][1] * Ixy[1][1])) - (0.07*((Ixx[1][1] + Iyy[1][1])  * (Ixx[1][1] + Iyy[1][1])))

#normalize
#Will take N*N cycles again to read (supercycle)
#store val += Img[x][y] in 64 bit reg and pass to convoluters
#cv2.normalize(harrisMatrix, harrisMatrix, 0, 1, cv2.NORM_MINMAX)

#search kernel
#Will take N*N cycles again to read [dividing by shared 64 bit reg] (supercycle)
#Will take N*N cycles again to write (supercycle)
for x in range(8):
    for y in range(8):
        if (harrisMatrix[x][y] > thresh):
            print(harrisMatrix[x][y], end=' ')
        else:
            print(harrisMatrix[0][0], end=' ')
    print("", end='\n')


