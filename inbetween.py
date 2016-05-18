import cv2
import tuio
import numpy as np
tracking = tuio.Tracking()
cap = cv2.VideoCapture('SAMPLE.AVI')

while True:
    if cap.isOpened():
        ret, img = cap.read()
        if ret == 0:
            cap.set(cv2.cv.CV_CAP_PROP_POS_FRAMES, 0)
            ret, img = cap.read()
        rows,cols, _ = img.shape
        tracking.update()
        tx = 0
        ty = 0
        rotation = 0
        for obj in tracking.objects():
            rotation = obj.angle
            tx = obj.xpos
            ty = obj.ypos

        rot_mat = cv2.getRotationMatrix2D((cols/2,rows/2),rotation,1)
        rot_move = np.dot(rot_mat, np.array([tx* cols,ty * rows, 0]))
        rot_mat[0,2] += rot_move[0]
        rot_mat[1,2] += rot_move[1]

        dst = cv2.warpAffine(img,rot_mat,(cols,rows))

        cv2.imshow('180_rotation', dst)
    key=cv2.waitKey(1)
    if key == 27:
        break

cv2.destroyAllWindows()
tracking.stop()
