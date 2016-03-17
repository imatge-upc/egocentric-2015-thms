#srun --pty --mem=4000mb --gres=gpu:1  python saliency.py  > ~/logs/sal.log 2>&1 &

from get_params import get_params
import sys, scipy.io, getopt
import os
import numpy as np
import matplotlib.pylab as plt
import pickle
#import cv2, glob
import glob

def main(argv):
    
    params = get_params() # check get_params.py in the same directory to see the parameters
    
    try:
      opts, args = getopt.getopt(argv,"hr:o:s:c:g:",["root=","out=","saliency_model=","caffe_path=", "gpu="])
    except getopt.GetoptError:
      print 'ERROR'
      sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
              print 'saliency.py -r <root> -o <out> -s <saliency_model> -c <caffe_path> -g <gpu>'
              sys.exit()
        elif opt in ("-r", "--root"):
              params['root'] = arg
        elif opt in ("-o", "--out"):
              params['out'] = arg
        elif opt in ("-s", "--saliency_model"):
              params['saliency_model'] = arg
        elif opt in ("-c", "--caffe_path"):
              params['caffe_path'] = arg
        elif opt in ("-g", "--gpu"):
              params['gpu'] = arg;
              
    sys.path.insert(0,os.path.join(params['caffe_path'],'python'))
    import caffe
    
    compute = 'True' # sys.argv[1] # write 'true' or 'false' in case you want to compute or just visualize
    
    
    if compute== 'true' or compute =='True':
        
        
        deploy_file = os.path.join(params['saliency_model'],'deploy.prototxt')
        model_file = os.path.join(params['saliency_model'],'model.caffemodel')
        # I am using the mean file from caffenet...but I guess we could use a grey image as well ?
        mean_file = '/media/HDD_2TB/mcarne/keyframe-extractor/src/Saliency/deep/meanfile.npy'
        
        if params['gpu'] == True:
            caffe.set_mode_gpu()
            print 'GPU mode selected'
        else: 
            caffe.set_mode_cpu()
            print 'CPU mode selected'
            
        net = caffe.Classifier(deploy_file, model_file, mean=np.load(mean_file).mean(1).mean(1), channel_swap=(2,1,0),raw_scale=255)
        if not os.path.exists(params['out']):
            os.makedirs(params['out'])
        
        for imagepath in glob.glob(params['root']+"/*.jpg"):
            print "Procressing image..."
            scores = net.predict([caffe.io.load_image(imagepath)])    
            feat = net.blobs['deconv1'].data
            #feat = np.reshape(feat, (10,4096))
            print feat, np.shape(feat)
            #meanfeat = np.average( feat, axis = 0 ) 
            # saves to disk
            fout = params['out']+'/'+os.path.splitext(os.path.basename(imagepath))[0];
            pickle.dump(feat,open(fout+'.p','wb'))
            scipy.io.savemat(fout+'.mat', mdict={'isal': feat})

if __name__ == "__main__":
   main(sys.argv[1:])
#else:
    
    
    #feat = pickle.load(open('saliency.p','rb'))
    #im = cv2.imread(imagepath)
    #print np.shape(im)
    #plt.imshow(np.array(feat).squeeze())

    #feat = np.resize(feat,(576,768) )
    #plt.show()