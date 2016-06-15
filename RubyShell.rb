require "fileutils"

$seqs = ["Basketball","Bird1","BlurBody","BlurCar2","BlurFace","BlurOwl","Box","Car1","Car4","Cardark","CarScale","ClifBar","Couple","Crowds","Deer","Diving","DragonBaby","Dudek","Freeman4","Human3","Human4","Human6","Human9","Ironman","Jumping","Jump","Liquor","Matrix","MotorRolling","Panda","RedTeam","Shaking","Singer2","Skating1","Skating2","Skiing","Soccer","Surfer","Sylvester","Tiger2","Trellis","Walking2","Walking","Woman","Bird2","BlurCar1","BlurCar3","BlurCar4","Board","Bolt2","Bolt","Boy","Car24","Car2","Coke","Coupon","Crossing","Dancer2","Dancer","David2","David3","David","Dog","Doll","FaceOcc1","FaceOcc2","Fish","FleetFace","Football1","Football","Freeman1","Freeman3","Girl2","Girl","Gym","Human2","Human5","Human7","Human8","Jogging1","Jogging2","kiteSurf","Lemming","Man","Mhyang","MountainBike","Rubik","Singer1","Skater2","Skater","Subway","Suv","Tiger1","Toy","Trans","Twinnings","Vase","Biker"]
$seqLength = ["725","408","334","585","493","631","1161","1020","659","393","252","471","140","347","71","231","113","1145","297","1698","667","792","305","166","313","122","1741","100","164","1000","1918","365","366","400","473","81","392","376","1345","365","569","500","412","597","99","988","395","397","698","293","350","602","3059","913","291","327","120","150","225","537","252","471","1350","127","3872","892","812","476","707","81","362","326","474","500","500","767","1128","713","250","128","307","307","84","1336","134","1490","228","1997","351","435","160","175","945","354","271","124","471","271","142"]
class RubyShell
	def d1 mainDir,resultDir,arithmetic,dataset
		Dir.chdir mainDir do |path|
			@src = resultDir.b
			Dir.chdir "trackers" do |path|
				FileUtils.mkdir_p arithmetic,:verbose => true
				Dir.chdir arithmetic do |path|
					FileUtils.mkdir_p 'results',:verbose => true
					@dest = Dir.pwd + "\\" + 'results'
					runFile = File.open "run_" + arithmetic.upcase + ".m","w+"
					runFile.puts "function results=run_#{arithmetic.upcase}(seq, res_path, bSaveImage)\nclose all\npath = './results/'\nresults.res = dlmread([path seq.name '_#{arithmetic.upcase}.txt']);\nresults.res(:,1:2) =results.res(:,1:2) + 1;\%c to matlab\nresults.type='rect';\nresults.fps = 1;\nresults.fps = 1;\nend"
				end
			end
			@results = Array.new	
			if @src[-1] != "\\" or @src[-1] != "/"
				@src << "\\"
			end
			Dir.foreach @src do |file|
				if file != "." and file != ".."
					FileUtils.cp_r @src + "\\" + file,@dest
					@results << (/[a-z]+\d*_/i.match file).to_s.chop if (/[a-z]+\d*_/i.match file) != nil
					@results.uniq!
				end
			end
			configSeqs = File.open path + "\\" + "util" + "\\" + "configSeqs.m", "a"
			configSeqs.puts 'seqs = [{'
			@configSeqsContext = String.new
			@results.each do |result|
				counter = 0
				$seqs.each do |seq|
					if seq == result
						break
					else
						counter += 1
					end 
				end
				@configSeqsContext << "\n\tstruct(\'name\',\'#{result}\',\'path\',\'#{dataset}\\#{result}\\\',\'startFrame\',1,\'endFrame\',#{$seqLength[counter]},\'nz\',4,\'ext\',\'jpg\',\'init_rect\', [0,0,0,0]),..."
			end 
			4.times do |i|
				@configSeqsContext.chop
			end
			configSeqs.puts @configSeqsContext
			configSeqs.puts "}];"
			configTrackers = File.open path + "\\" + "util" + "\\" + "configTrackers.m","a"
			configTrackers.puts "\ntrackers = [{"
			configTrackers.puts "\tstruct(\'name\',\'#{arithmetic.upcase}\',\'namePaper\',\'#{arithmetic.upcase}\')"
			configTrackers.puts "}];"
		end
	end
	def d2 root,arithmeticArray
		
	end
	def rename root,arithmetic
		rootPath = root.b
		fileHash = Hash.new
		if rootPath[-1] != "\\" or root[-1] != "/"
			rootPath << "\\"
		end
		Dir.foreach rootPath do |file|
			$seqs.length.times do |a|
				if file.match /#{$seqs[a]}(.)*\.txt/i
					fileHash.update file => $seqs[a]
					break 				 	
				end 
			end 
		end
		fileHash.each_key do |key1|
			counter = 0
			fileHash.each_key do |key2|
				if key1 == key2
					if counter > 0 
						puts "错误，存在文件名相似的结果文件"
						return
					end
					counter += 1
				end
			end
		end
		puts fileHash
		fileHash.each do |key1,key2|
			File.rename rootPath + "\\" + key1,rootPath + "\\" + key2 + "_1_" + arithmetic.upcase + ".txt"
			19.times do |i|
				FileUtils.cp rootPath + "\\" + key2 + "_1_" + arithmetic.upcase + ".txt",rootPath + "\\" + key2 + "_" + "#{i+2}" +"_" + arithmetic.upcase + ".txt"
			end
		end
	end
	def existCheck a 
		if a == "-d"
			if !(Dir.exist? ARGV[1])
				puts ARGV[1] + "，输入的基准程序主目录不存在"
				return
			end
			if !(Dir.exist? ARGV[2])
				puts ARGV[2] + "，输入的算法结果目录不存在"
				return
			end
			if ARGV[3].empty?
				puts "输入的您的算法名"
				return
			end
			if !(Dir.exist? ARGV[4])
				puts ARGV[4] + "输入的数据集目录不存在"
				return
			end
			d1 ARGV[1],ARGV[2],ARGV[3],ARGV[4]
		end
		if a == "-d2"
			arithmeticArray = Array.new
			ARGV.shift
			ARGV.each do |arithmetic|
				arithmeticArray << arithmetic
			end
			d2 arithmeticArray
		end
		if a == "-rn"
			if !(Dir.exist? ARGV[1])
				puts ARGV[1] + "，输入的路径不存在"
				return
			end
			if ARGV[2].empty?
				puts "请输入您的算法名"
				return
			end
			rename ARGV[1],ARGV[2]
		end
		if a == "--help"
			puts "此脚本的作用是可以自动部署cvpr2013_benchmark来评估自己算法，用法如下：\n-rn [要重命名的文件所在的文件夹] [算法名] 作用：用于将文件夹下的结果文件命名为benchmark能识别的格式\n-d [benchmark所在目录] [结果目录] [算法名] [dataset所在目录] 作用：能够自动部署benchmark，运行完脚本请打开matlab运行下man_running.m。\033[33m注意：要用TRE运行\033[0m"
			puts "\n从头开始配置一个benchmark需要做一些简单的工作：\n\t1.先到网站上下载基准程序：http://cvlab.hanyang.ac.kr/tracker_benchmark/benchmark_v10.html\n\t2.下载vlfeat-0.9.20，将vlfeat-0.9.20放进benchmark主目录下，然后修改main_running.m中的关于vlfeat的一行，把vlfeat路径设置正确。\n\t3.修改genPerfMat.m文件，将里面的SRE去掉（如果只要评估OPE或TRE的话不用SRE）。\n\t4.将基准程序中的rstEVAL文件夹下的文件拷到基准程序主文件夹下。\n\t然后就可以开始配置自己的算法了。"
		end
	end
end
RubyShell.new.existCheck ARGV[0]
