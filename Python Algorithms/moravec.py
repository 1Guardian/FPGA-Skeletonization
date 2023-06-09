import cv2
import getopt
import sys

def __main__(argv):

    imagename = ""
    cycles = 200

    try:
        opts, args = getopt.getopt(argv,"i:c:")

    except getopt.GetoptError:
            print("./exe -i <image-name>")
            print("===========================================================================================================")
            print("-i : Target Image (i)")
            print("-c : Target cycles (c)")
            sys.exit(2)
    for opt, arg in opts:

        if opt == ("-h"):
            print("./exe -i <image-name>")
            print("===========================================================================================================")
            print("-i : Target Image (i)")
            print("-c : Target cycles (c)")

        elif opt == ("-i"):
            imagename = arg
        elif opt == ("-c"):
            cycles = int(arg)

    threshold = 1000

    #image stuff
    input_img = cv2.imread(imagename, 0)
    cv2.imshow('Input Image', input_img)
    cv2.waitKey(0)

    output_img = cv2.cvtColor(input_img.copy(), cv2.COLOR_GRAY2RGB)
    final_img = cv2.cvtColor(input_img.copy(), cv2.COLOR_GRAY2RGB)

    #each unique shift for the corners
    xy_1_shifts = [(-1, 0), (-1, -1), (0, -1), (1, -1)]
    xy_2_shifts = [(0, -1), (1, -1), (1, 0), (1, 1)]
    xy_3_shifts = [(1, 0), (1, 1), (0, 1), (-1, 1)]
    xy_4_shifts = [(0, 1), (-1, 1), (-1, 0), (-1, -1)]

    #begin process
    for i in range(cycles):
        for x in range(1, input_img.shape[0]-1):
            for y in range(1, input_img.shape[1]-1):
                
                if (input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1]):
                    continue

                if (input_img[x, y] > 0 and input_img[x+1, y] == input_img[x-1, y] == input_img[x, y+1] == input_img[x, y-1] == 0):
                    continue
                
                #thresholds
                E1 = 100000
                E2 = 100000
                E3 = 100000
                E4 = 100000
                
                #check each position for a corner
                for shift in xy_1_shifts:
                    diff = ((int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])) * (int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])))
                    E1 = diff if (diff < E1) else E1

                for shift in xy_2_shifts:
                    diff = ((int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])) * (int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])))
                    E2 = diff if (diff < E2) else E2
                
                for shift in xy_3_shifts:
                    diff = ((int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])) * (int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])))
                    E3 = diff if (diff < E3) else E3

                for shift in xy_4_shifts:
                    diff = ((int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])) * (int(input_img[x + shift[0], y + shift[1]]) - int(input_img[x, y])))
                    E4 = diff if (diff < E4) else E4
                    
                if E1 > threshold or E2 > threshold or E3 > threshold or E4 > threshold:
                    final_img[x,y] = (255,255,255)
                    output_img[x,y] = (255,255,255)
                else:
                    output_img[x,y] = (255,255,255)
                
                if i == cycles-1 and input_img[x, y] != 255:
                    final_img[x,y] = (255,255,255)

        #duplicate image and show skeleton overlayed
        input_img = cv2.cvtColor(output_img.copy(), cv2.COLOR_BGR2GRAY)
        output_img = cv2.cvtColor(input_img.copy(), cv2.COLOR_GRAY2BGR)


    #dilate final image to make easier to see
    final_img = cv2.dilate(final_img, None)

    cv2.imshow('Detected Corners', final_img)
    cv2.waitKey(0)

#start main
argv = ""
__main__(sys.argv[1:])