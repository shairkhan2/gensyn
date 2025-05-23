<div align="center">

# 💻 Gensyn-ai-Rl-Swarm_Guide {Mac/Linux} 💻

</div>


# Device/System Requirements 🖥️

![image](https://github.com/user-attachments/assets/4fbf23bb-846c-4def-be24-157c51fa0b4e)



* Open Your Vps
# automate/single click 🛠
```
curl -fsSL -o menu.sh https://raw.githubusercontent.com/shairkhan2/gensyn/main/menu.sh && \
chmod +x menu.sh && \
./menu.sh

```


# Pre-Requirements 🛠

# Install Python and Other Tools

* For **Linux/Wsl**

```
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof

```

Check Version

```
python3 --version
```


# Install Node.js , npm & yarn

* For **Linux/Wsl**

```
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt update && sudo apt install -y nodejs
```

* Install Yarn (linux)

```
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
```

```
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null
```

```
sudo apt update && sudo apt install -y yarn
```

* Check version **(Linux/ubuntu)**

```
node -v
```
```
npm -v
```

```
yarn -v
```


<div align="center">

# 👨🏻‍💻 Start The Node (Linux/ubuntu) 

</div>


* 1️⃣ Clone RL-SWARM Repo

```
git clone https://github.com/gensyn-ai/rl-swarm.git
```


* 2️⃣ Create a screen session **(vps)**

```
screen -S gensyn
````

* 3️⃣ Navigate to rl-swarm

```
cd rl-swarm
```

* 4️⃣ Create & Activate a Virtual Environment

```
python3 -m venv .venv
source .venv/bin/activate
```

* 5️⃣ Run the swarm Node 🚀


```
./run_rl_swarm.sh
```

- After Running the Above command it will promt `Would you like to connect to the Testnet? [Y/n]` Enter `Y`

- After than it will promt `>> Which swarm would you like to join (Math (A) or Math Hard (B))? [A/b]`  Enter   `a`

- After than it will promt `>> How many parameters (in billions)? [0.5, 1.5, 7, 32, 72]`    

👇See below and Choose the model Depends on Your System! 

<pre>
- Qwen 2.5 0.5B                - Recommended 4GB RAM, (1GB DOWNLOAD)
- Qwen 2.5 1.5B                - Recommended 8GB RAM, (4GB DOWNLOAD)
- Qwen 2.5 7B                  - Recommended 16GB RAM, (15GB DOWNLOAD)
- Qwen 2.5 32B (4 bit)         - Recommended 50GB RAM, (35GB DOWNLOAD)
- Qwen 2.5 72B (4 bit)         - Recommended 100GB RAM, (70GB DOWNLOAD)
</pre>
    
- After that A web Pop-Up will appear, It will ask u to Login ( if no web pop-up then u have to paste this on ur brower `http://localhost:3000/` 


- Now Login With Your Email Id, Enter OTP and back to ur Terminal/Wsl? **( VPS users check FAQ1 )**

![image](https://github.com/user-attachments/assets/1fed4b08-4ec4-44de-868c-b2d314cd2a02)


- Now U can see A `ORG_ID` On ur Terminal..Save it!


* Now It will promt `Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N]` Enter `N`

<img width="1223" alt="Screenshot 2025-05-01 at 4 47 30 PM" src="https://github.com/user-attachments/assets/05fcfc61-b562-4089-b21f-ba95b1036a24" />




![image](https://github.com/user-attachments/assets/33344c45-a108-4671-af31-a5e431878736)


Here we go🚀

Its Done ✅

It will Generate Logs Soon🙌


* Detach from `screen session` **(vps)**

Use `Ctrl + A` and then press `D`

* Attach to gensyn Screen to see Logs

```
screen -r gensyn
```



<div align="center">

#  🛠 FAQ & Troubleshoot 🛠

</div>


# 1️⃣ How to Login or access  http://localhost:3000/ in VPS? 📶

* Open a new Terminal and login ur vps 


* Install cloudflared on the VPS

```
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
````

```
sudo dpkg -i cloudflared-linux-amd64.deb
```

* Check version

```
cloudflared --version
```

* Make sure your Node is running on port 3000 in Previous Screen

* Run the tunnel command

```
cloudflared tunnel --url http://localhost:3000
```

* Access the Link from your local machine

    
    ![image](https://github.com/user-attachments/assets/c5bdfec5-123d-4625-8da8-f46269700950)

* Now follow Login!
 
* Done!✅


#  🛠 loading page issue 🛠

1. Navigate to the project folder
2.
 ```
   cd rl-swarm
 ```

   3.Open the file for editing
```
sudo apt update && sudo apt install nano -y
```
  ```
nano modal-login/app/page.tsx
```
4.Use the arrow keys to scroll down in this file and look for this line:
return (main className="flex min-h-screen flex-col items-center gap-4 justify-center text-center>

5.Just above that return line, paste the following code (make sure there is one line of space between the pasted code and the return line, and that the indentation matches):
```
useEffect(() => {
     if (!user && !signerStatus.isInitializing) {
       openAuthModal(); 
     }
   }, [user, signerStatus.isInitializing]);
```
6.Save the file by pressing:
Ctrl + O  (then press Enter)
Ctrl + X  (to exit nano)
7.Restart Node with the following command
```
python3 -m venv .venv && . .venv/bin/activate && ./run_rl_swarm.sh
```

#  🛠  Daemon's timeout ISSUE 🛠
1. Navigate to the project folder
2. ```
   cd rl-swarm
   ```
3.Open the file
```
nano $(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
```
4. press CTRL+W to search line
```
startup_timeout
```
5. change the line from
startup_timeout: float = 15 to startup_timeout: float = 120
6.Save the file by pressing:
Ctrl + O  (then press Enter)
Ctrl + X  (to exit nano)

7. Restart Node with the following command
 ```
   ./run_rl_swarm.sh
   ```

#  🛠 UnboundLocalError: cannot access local variable 'current_batch' 🛠

1.run this on rl-swarm folder
```
cd $HOME/rl-swarm/

RL_SWARM_UNSLOTH=False ./run_rl_swarm.sh
```
FOR OLD FILE/REPO THIS CMD WORKING
```
cd $HOME/rl-swarm/hivemind_exp/configs/mac/ && \
sed -i \
  -e 's/torch_dtype: .*/torch_dtype: float32/' \
  -e 's/bf16: .*/bf16: false/' \
  -e 's/tf32: .*/tf32: false/' \
  -e 's/gradient_checkpointing: .*/gradient_checkpointing: false/' \
  -e 's/per_device_train_batch_size: .*/per_device_train_batch_size: 2/' \
grpo-qwen-2.5-0.5b-deepseek-r1.yaml && cd
```


