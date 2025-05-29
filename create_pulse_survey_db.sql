-- ============================================================================
-- DIMENSION TABLES (Create first due to foreign key dependencies)
-- ============================================================================

-- Geographic Areas Dimension Table
-- Stores master list of geographic locations for survey coverage
CREATE OR REPLACE TABLE GEOGRAPHIC_AREAS (
    geo_id INTEGER NOT NULL,
    geo_code VARCHAR(50),
    geo_name VARCHAR(200),
    geo_type VARCHAR(50),
    fips_code VARCHAR(2),
    -- Primary key constraint
    CONSTRAINT pk_geographic_areas PRIMARY KEY (geo_id)
) COMMENT = 'Master table of geographic areas where surveys are conducted';

-- Demo Groups Dimension Table  
-- Stores demographic classifications for survey analysis
CREATE OR REPLACE TABLE DEMO_GROUPS (
    demo_id INTEGER NOT NULL,
    demo_option VARCHAR(100),
    demo_category VARCHAR(100),
    -- Primary key constraint
    CONSTRAINT pk_demo_groups PRIMARY KEY (demo_id)
) COMMENT = 'Demographic classification system for survey respondents';

-- Questions Dimension Table
-- Master list of survey questions with display names
CREATE OR REPLACE TABLE QUESTIONS (
    question_id INTEGER NOT NULL,
    question VARCHAR(500),
    question_short_name VARCHAR(100),
    -- Primary key constraint
    CONSTRAINT pk_questions PRIMARY KEY (question_id)
) COMMENT = 'Master list of survey questions';

-- Responses Dimension Table
-- Standardized response options across all surveys
CREATE OR REPLACE TABLE RESPONSES (
    response_id INTEGER NOT NULL,
    response VARCHAR(200),
    response_short_name VARCHAR(50),
    -- Primary key constraint
    CONSTRAINT pk_responses PRIMARY KEY (response_id)
) COMMENT = 'Standardized response options for survey questions';

-- ============================================================================
-- data TABLE (Create after dimension tables)
-- ============================================================================

-- Pulse Survey data Table
-- Central table storing survey response data with foreign key relationships
CREATE OR REPLACE TABLE PULSE_SURVEY (
    cycle_type VARCHAR(50),
    cycle_number INTEGER,
    geo_id INTEGER NOT NULL,
    demo_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    response_id INTEGER NOT NULL,
    value INTEGER,
    -- Foreign key constraints to ensure referential integrity
    CONSTRAINT fk_pulse_survey_geo 
        FOREIGN KEY (geo_id) REFERENCES GEOGRAPHIC_AREAS(geo_id),
    CONSTRAINT fk_pulse_survey_demo 
        FOREIGN KEY (demo_id) REFERENCES DEMO_GROUPS(demo_id),
    CONSTRAINT fk_pulse_survey_question 
        FOREIGN KEY (question_id) REFERENCES QUESTIONS(question_id),
    CONSTRAINT fk_pulse_survey_response 
        FOREIGN KEY (response_id) REFERENCES RESPONSES(response_id)
) COMMENT = 'Central data table storing survey response data across cycles, geography, demographics, and questions';

-- ============================================================================
-- PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Cluster the data table on frequently queried columns for better performance
-- Adjust clustering keys based on your most common query patterns
ALTER TABLE PULSE_SURVEY
CLUSTER BY (geo_id, cycle_number, question_id);