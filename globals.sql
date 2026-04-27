--
-- PostgreSQL database cluster dump
--

\restrict hgXrMl4G8sYmeOETeoAUoiHZlgVeObSwqX3d0JWsrUrevaoz7rBvsqMTgWzT8NH

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE ciot;
ALTER ROLE ciot WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:ozDjJpnMBvL2BCbwWnXg7w==$PTz+tvmAZ4n7UcUUniicZ8wHW7GTw7806TAl9KUuCCg=:ZyyK5IdYT8s0fwcUsya/Jl/QI62ALZC/UdtYhRSZoH0=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;

--
-- User Configurations
--








\unrestrict hgXrMl4G8sYmeOETeoAUoiHZlgVeObSwqX3d0JWsrUrevaoz7rBvsqMTgWzT8NH

--
-- PostgreSQL database cluster dump complete
--

