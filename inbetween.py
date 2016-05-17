# import tuio

# tracking = tuio.Tracking()
# try:
#     while 1:
#         tracking.update()
#         for obj in tracking.objects():
#             print obj
# except KeyboardInterrupt:
#         tracking.stop()


import cv2
import tuio
tracking = tuio.Tracking()
cap = cv2.VideoCapture('video.mov')
# img = cv2.imread('tmp.png',0)
# rows,cols = img.shape
# cv2.namedWindow("test", cv2.WND_PROP_FULLSCREEN)
# cv2.setWindowProperty("test", cv2.WND_PROP_FULLSCREEN, cv2.cv.CV_WINDOW_FULLSCREEN)


rotation = 0
while True:
    if cap.isOpened():
        print "helloo"
        ret, frame = cap.read()
        img = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        tracking.update()
        for obj in tracking.objects():
            rotation = obj.angle
        M = cv2.getRotationMatrix2D((cols/2,rows/2),rotation,1)
        dst = cv2.warpAffine(img,M,(cols,rows))

        cv2.imshow('180_rotation', dst)
    key=cv2.waitKey(1)
    if key == 27:
        break

cv2.destroyAllWindows()
tracking.stop()
