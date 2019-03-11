ffmpeg -i xx.mp4 out.wav
 //剥离视频中音频副
ffmpeg -i  noise.mp4 noise.wav
 //抽取噪声标本视频中的噪音样本
sox noise.wav -n noiseprof noise.prof
 //生成噪音prof文件
sox out.wav  out-noise-free.wav noisered noise.prof 0.2(0.2-0.5)
 //利用noise.prof文件去除音频中的噪音，生成无噪音音频
ffmpeg -i 22.mp4 -i out-noise-free.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 128k output22.mp4
//将无噪音视频和视频文件组和，输出output22.mp4
~                                             
