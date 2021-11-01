module(...,package.seeall)
List = List or {} 
function List:InitSequece(length) 
    self.m_QueCapacity = length 
    self.length = 0 
    self.m_head = 0 
    self.m_iTail = 0 
    self.list = {} 
end
function List:DeleteSequece() 
   self.list = {} 
   self.list = nil 
   self.length = 0 
   self.m_head = 0 
   self.m_iTail = 0 
end
function List:ClearSequece() 
   self.length = 0 
   self.m_head = 0 
   self.m_iTail = 0 
end
function List:QueueEmpty() 
    if 0 == self.length then 
        return true 
    end 
    return false 
end
function List:QueueLength() 
    return self.length 
end
function List:QueueNull() 
    if self.length == self.m_QueCapacity then 
        return true 
    end 
    return false 
end
function List:EnQueue(number) 
    if self:QueueNull() then 
        -- return false 
        self:DeQueue(1)
    end 
    self.list[self.m_iTail % self.m_QueCapacity] = number 
    self.m_iTail = self.m_iTail + 1 
    self.length = self.length + 1 
    return true 
end
function List:DeQueue(number) 
    if self:QueueEmpty() then 
        return false 
    end 
    number = self.list[self.m_head] 
    self.m_head = self.m_head + 1 
    self.m_head = self.m_head % self.m_QueCapacity 
    self.length = self.length - 1 
    return true and number 
end
function List:QuueTraverse() 
    for i = self.m_head , self.length + self.m_head - 1 do 
        print("打印队列中的元素",self.list[i%self.m_QueCapacity]) 
    end 
end

function List:GetAdd()
    local sum=0
    for i = self.m_head , self.length + self.m_head - 1 do 
        sum = sum + self.list[i%self.m_QueCapacity]
    end 
    return sum
end

function List:main() 
    
    self:InitSequece(4) 
    self:EnQueue(1) 
    self:EnQueue(2) 
    self:EnQueue(3) 
    self:EnQueue(4) 
    local number = nil 
    -- print(self:DeQueue(number) , "kkkkkkkkkkkkk") 
    -- print(self:DeQueue(number) , "kkkkkkkkkkkkk") 
    -- print(self:DeQueue(number) , "kkkkkkkkkkkkk") 
    -- print(self:DeQueue(number) , "kkkkkkkkkkkkk") 
    if self:QueueEmpty() then 
        print("当前队列已经空了") 
    else 
        print("2222222222222222222") 
    end 
end

function reList()
    return List
end
