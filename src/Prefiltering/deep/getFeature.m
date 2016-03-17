function feat = getFeature(features, iname)
    feat= features(features(:,1)==iname,2:end);
end