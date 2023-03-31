CREATE OR REPLACE FUNCTION call_openai(query TEXT) RETURNS JSONB AS $$
DECLARE 
    completionConfig jsonb;
    response text;
    payload text;
    result jsonb;

BEGIN 

-- Check if query empty string
    IF length(query) < 1 THEN 
        RETURN NULL;
    END IF;

-- Openai completion configurations
    completionConfig := jsonb_build_object(
        'model','gpt-3.5-turbo',
        'messages',jsonb_build_array(jsonb_build_object('role','user','content',query)),
         'max_tokens',500,
         'temperature', 0);

-- Convert jsonb into text
    payload := completionConfig::text;

-- Call openai api
    SELECT content::jsonb into response FROM http((
          'POST',
           'https://api.openai.com/v1/chat/completions',
           ARRAY[http_header('Authorization', 'Bearer *api-key-here*')],
           'application/json',
           payload
        )::http_request);

-- Convert response to json
    result := jsonb_build_object('response', response::jsonb);
    RETURN result;

END;
$$ LANGUAGE plpgsql;
