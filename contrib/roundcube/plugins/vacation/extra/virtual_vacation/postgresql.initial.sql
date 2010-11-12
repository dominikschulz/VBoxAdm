--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: vacation; Type: TABLE; Schema: public; Owner: postfix; Tablespace:
--

CREATE TABLE vacation (
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255)
);


ALTER TABLE public.vacation OWNER TO postfix;

--
-- Name: vacation_pkey; Type: CONSTRAINT; Schema: public; Owner: postfix; Tablespace:
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_pkey PRIMARY KEY (email);


--
-- Name: vacation_email_active; Type: INDEX; Schema: public; Owner: postfix; Tablespace:
--

CREATE INDEX vacation_email_active ON vacation USING btree (email, active);


--
-- Name: vacation_domain_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postfix
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_domain_fkey1 FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- PostgreSQL database dump complete


--
-- Name: vacation_notification; Type: TABLE; Schema: public; Owner: postfix; Tablespace:
--

CREATE TABLE vacation_notification (
    on_vacation character varying(255) NOT NULL,
    notified character varying(255) NOT NULL,
    notified_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.vacation_notification OWNER TO postfix;

--
-- Name: vacation_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postfix; Tablespace:
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_pkey PRIMARY KEY (on_vacation, notified);


--
-- Name: vacation_notification_on_vacation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postfix
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_on_vacation_fkey FOREIGN KEY (on_vacation) REFERENCES vacation(email) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

