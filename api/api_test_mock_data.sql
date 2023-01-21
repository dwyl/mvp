-- Adding single mock item
INSERT INTO public.items
("text", person_id, status, inserted_at, updated_at)
VALUES('random text', 0, 2, '2023-01-19 13:48:12.000', '2023-01-19 13:48:12.000');

-- Adding two timers 
INSERT INTO public.timers
("start", stop, item_id, inserted_at, updated_at)
VALUES('2023-01-19 15:52:00', '2023-01-19 15:52:03', 1, '2023-01-19 15:52:03.000', '2023-01-19 15:52:03.000'),
('2023-01-19 15:55:00', null, 1, '2023-01-19 15:52:03.000', '2023-01-19 15:52:03.000');
