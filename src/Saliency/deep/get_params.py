def get_params():

    params = {'root': '/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1/', # all data is stored here
              'out' : '/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/saliency/',
              'gpu' : True, # use gpu for feature extraction or not
              'query_name': 'all_frames',
              'height' : 768,
              'width' : 576,
              'region_detector': 'selective_search',
              'net': 'fast-rcnn', # rcnn and sppnet were used in the early stages
              'length_ranking': 1000, # length of the list to rerank
              'fusion_alpha':0.5,
              'use_proposals':False,
              'database': 'db',
              'fusion-scheme':'all', # 'bow-frcnn', 'frcnn-dpm', 'all'
              'year': '2014',
              #'batch_size': 3000, # number of boxes that can be processed at once
              'batch_size': 1,
              'baseline': 'nii_bow', #nii_bow
              'display_baseline': False,
              'delete_mode': False,
              'saliency_model': '/media/HDD_2TB/mcarne/keyframe-extractor/src/Saliency/deep',
              'places_model': '',
              'distance_type':'scores01-sw', # euclidean, or scores
              'caffe_path': '/usr/local/caffe-dev/matlab/caffe', #where caffe is installed and compiled
              'fast_rcnn_path': '', # where fast-rcnn is installed and compiled
              'num_frames': 1614, # unused
              'num_candidates':2000, # max number of object candidates to use at test time
              'split_percentage':0.8, # split train/val for svm
              'additional_negatives': True,
              'num_additional': 1000000,
              'svm_iterations': 1,
              'min_negatives': 1,
              'layer' : 'cls_score_trecvid', #cls_prob
              'net_name': 'trecvid'}

    return params