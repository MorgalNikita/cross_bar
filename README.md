# Cross-bar 2x2

##### 1)rtl - Исходники
  - cross_bar.sv -  модуль для коммутации 2 ведущих и 2 ведомых устройств;
  - master_cpu.sv - блок для тестирования cross-bar, ведущий интерфейс. Генерирует случайные транзакции в cross-bar;
  - slave_ram.sv - блок для тестирования cross-bar, ведомый интефейс. Отвечает на принятые транзакции;
  - round_robin.sv - арбитраж входящих запросов по дисциплине "round_robin" на ведомое устройство при единовременном доступе с ведущих;
  
##### 2)tb - Топовый уровень для тестирования cross_bar.sv + round_robin.sv
  - tb.sv - блок для подключения ведущих и ведомых устройств к cross-bar
  
##### 3)make_sim.do - do скрипт для автоматизации запуска проекта
  - Запуск - Моделирование проводилось в RTL симуляторе ModelSim 10.1d
  -  VSIM>cd c:/../../../../cross_bar
  -  VSIM>do make_sim.do
    
    
Syntacore task
